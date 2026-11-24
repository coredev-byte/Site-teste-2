--!strict
-- HUD contextual do ELEVATOR: mostra só o que importa no estado atual.
-- Blocos: Profile (lobby), Floor, Run (sobreviventes/streak/recompensa), Objective,
-- Intro do andar, Transição do elevador, Lobby, Checkpoint, Resultados e Toasts.
-- Andares customizam o objetivo via snapshot (Objective + ObjectiveSwatch) — sem HUDs separadas.

local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Theme = require(Shared.UI.Theme)
local Progression = require(Shared.Util.Progression)
local Components = require(script.Parent.Parent.UI.Components)
local StateController = require(script.Parent.StateController)

local make = Components.make
local text = Components.text
local C = Theme.Color
local S = Theme.Space

local player = Players.LocalPlayer

local InterfaceController = {}
InterfaceController.Root = (nil :: any) :: Frame

local ui: { [string]: any } = {}
local phaseDuration = 1
local lastState = ""

-- Layout responsivo ----------------------------------------------------------

local function computeScale(viewport: Vector2): number
	local ref = Theme.ReferenceResolution
	local s = math.min(viewport.X / ref.X, viewport.Y / ref.Y)
	return math.clamp(s, Theme.MinScale, Theme.MaxScale)
end

local function applyScale(root: Frame, uiScale: UIScale)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local s = computeScale(camera.ViewportSize)
	uiScale.Scale = s
	-- Compensa o UIScale para o root continuar cobrindo a tela inteira.
	root.Size = UDim2.fromScale(1 / s, 1 / s)
end

-- Construção -------------------------------------------------------------------

local function statRow(label: string, value: string, order: number): (Frame, TextLabel)
	local valueLabel = text("BodyLarge", value, { FontFace = Theme.Font.Mono, TextColor3 = C.Text, LayoutOrder = 2 })
	local row = make("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = order,
	}, {
		Components.list(Enum.FillDirection.Horizontal, S.M),
		text("Eyebrow", label, { LayoutOrder = 1, Size = UDim2.fromOffset(92, 0), AutomaticSize = Enum.AutomaticSize.Y }),
		valueLabel,
	})
	local layout = row:FindFirstChildOfClass("UIListLayout") :: UIListLayout
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	return row, valueLabel
end

local function build(): ScreenGui
	local gui = make("ScreenGui", {
		Name = "ElevatorHUD",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 10,
	})

	local uiScale = make("UIScale", {})
	local root = make("Frame", {
		Name = "Root",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = gui,
	}, { uiScale, Components.padding(S.L) })
	InterfaceController.Root = root
	ui.uiScale = uiScale

	-- PROFILE (lobby, canto superior esquerdo)
	local profileLevel = text("Display", "01", { LayoutOrder = 2 })
	local profileCoins = text("Body", "0 COINS", { TextColor3 = C.TextMuted, LayoutOrder = 3, FontFace = Theme.Font.Mono })
	ui.profile = Components.fadeGroup({ Name = "Profile", Parent = root })
	local profilePanel = Components.panel({ Parent = ui.profile })
	Components.list(Enum.FillDirection.Vertical, S.XS).Parent = profilePanel
	text("Eyebrow", "PASSENGER LEVEL", { LayoutOrder = 1 }).Parent = profilePanel
	profileLevel.Parent = profilePanel
	profileCoins.Parent = profilePanel
	ui.profileLevel = profileLevel
	ui.profileCoins = profileCoins

	-- FLOOR (canto superior esquerdo durante a partida)
	ui.floor = Components.fadeGroup({ Name = "Floor", Parent = root })
	local floorPanel = Components.panel({ Parent = ui.floor })
	Components.list(Enum.FillDirection.Vertical, S.XS).Parent = floorPanel
	text("Eyebrow", "FLOOR", { LayoutOrder = 1 }).Parent = floorPanel
	ui.floorNumber = text("Display", "--", { LayoutOrder = 2, Parent = floorPanel })
	ui.floorName = text("Body", "", { LayoutOrder = 3, TextColor3 = C.TextMuted, Parent = floorPanel })

	-- RUN (canto superior direito)
	ui.run = Components.fadeGroup({
		Name = "Run",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Parent = root,
	})
	local runPanel = Components.panel({ Parent = ui.run })
	Components.list(Enum.FillDirection.Vertical, S.S).Parent = runPanel
	local r1, survivors = statRow("SURVIVORS", "00/00", 1)
	local r2, streak = statRow("STREAK", "x1.0", 2)
	local r3, reward = statRow("RUN", "+0", 3)
	r1.Parent = runPanel
	r2.Parent = runPanel
	r3.Parent = runPanel
	ui.survivors, ui.streak, ui.reward = survivors, streak, reward
	streak.TextColor3 = C.Accent

	-- OBJECTIVE (topo central)
	ui.objective = Components.fadeGroup({
		Name = "Objective",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Parent = root,
	})
	local objPanel = Components.panel({ Parent = ui.objective })
	Components.list(Enum.FillDirection.Vertical, S.S).Parent = objPanel
	local header = make("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = 1,
		Parent = objPanel,
	}, { Components.list(Enum.FillDirection.Horizontal, S.S) })
	ui.swatch = make("Frame", {
		Size = UDim2.fromOffset(14, 14),
		BorderSizePixel = 0,
		Visible = false,
		LayoutOrder = 1,
		Parent = header,
	}, { make("UIStroke", { Color = C.Text, Transparency = 0.4 }) })
	ui.rule = text("Title", "", { LayoutOrder = 2, Parent = header })
	ui.timer = text("Display", "00:00", { LayoutOrder = 3, TextSize = Theme.TextSize.Title, Parent = header })
	ui.objectiveText = text("Body", "", {
		LayoutOrder = 2,
		TextWrapped = true,
		Size = UDim2.fromOffset(440, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = objPanel,
	})
	local bar, setBar = Components.progressBar()
	bar.LayoutOrder = 3
	bar.Size = UDim2.fromOffset(440, 3)
	bar.Parent = objPanel
	ui.setObjectiveBar = setBar

	-- INTRO DO ANDAR (centro)
	ui.intro = Components.fadeGroup({
		Name = "FloorIntro",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		Parent = root,
	})
	local introFrame = make("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = ui.intro,
	}, { Components.list(Enum.FillDirection.Vertical, S.S, Enum.HorizontalAlignment.Center) })
	ui.introEyebrow = text("Eyebrow", "FLOOR 00", { LayoutOrder = 1, Parent = introFrame, TextColor3 = C.Accent })
	ui.introRule = text("Hero", "", { LayoutOrder = 2, Parent = introFrame, TextXAlignment = Enum.TextXAlignment.Center })
	Components.divider(UDim.new(0, 120)).Parent = introFrame
	ui.introObjective = text("BodyLarge", "", {
		LayoutOrder = 4,
		Parent = introFrame,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromOffset(560, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local introDivider = introFrame:FindFirstChildWhichIsA("Frame")
	if introDivider then
		introDivider.LayoutOrder = 3
	end

	-- TRANSIÇÃO DO ELEVADOR (centro)
	ui.transition = Components.fadeGroup({
		Name = "Transition",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.92),
		Parent = root,
	})
	local tPanel = Components.panel({ Parent = ui.transition })
	Components.list(Enum.FillDirection.Vertical, S.XS, Enum.HorizontalAlignment.Center).Parent = tPanel
	text("Eyebrow", Theme.Copy.Unknown, { LayoutOrder = 1, Parent = tPanel })
	ui.transitionNumber = text("Display", "--", { LayoutOrder = 2, Parent = tPanel })

	-- LOBBY (base central)
	ui.lobby = Components.fadeGroup({
		Name = "Lobby",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.95),
		Parent = root,
	})
	local lPanel = Components.panel({ Parent = ui.lobby })
	Components.list(Enum.FillDirection.Vertical, S.XS, Enum.HorizontalAlignment.Center).Parent = lPanel
	ui.lobbyEyebrow = text("Eyebrow", "NEXT ELEVATOR", { LayoutOrder = 1, Parent = lPanel })
	ui.lobbyTimer = text("Display", "--:--", { LayoutOrder = 2, Parent = lPanel })
	ui.lobbyStatus = text("Body", Theme.Copy.Waiting, { LayoutOrder = 3, TextColor3 = C.TextMuted, Parent = lPanel })
	text("Eyebrow", Theme.Copy.Tagline, { LayoutOrder = 4, Parent = lPanel, TextTransparency = 0.4 })

	-- CHECKPOINT (centro)
	ui.checkpoint = Components.fadeGroup({
		Name = "Checkpoint",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = root,
	})
	local cPanel = Components.panel({ Parent = ui.checkpoint })
	local cpPadding = cPanel:FindFirstChildOfClass("UIPadding")
	if cpPadding then
		cpPadding:Destroy()
	end
	Components.padding(S.XL).Parent = cPanel
	Components.list(Enum.FillDirection.Vertical, S.M, Enum.HorizontalAlignment.Center).Parent = cPanel
	text("Eyebrow", "CHECKPOINT", { LayoutOrder = 1, Parent = cPanel, TextColor3 = C.Accent })
	ui.cpTitle = text("Title", "FLOOR 03 CLEARED", { LayoutOrder = 2, Parent = cPanel })
	text("Body", "Extract now and keep your rewards — or ride on for a bigger multiplier.", {
		LayoutOrder = 3,
		Parent = cPanel,
		TextColor3 = C.TextMuted,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromOffset(460, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local cpStats = make("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = 4,
		Parent = cPanel,
	}, { Components.list(Enum.FillDirection.Vertical, S.XS) })
	local c1, cpReward = statRow("AT STAKE", "+0", 1)
	local c2, cpMult = statRow("MULTIPLIER", "x1.0", 2)
	c1.Parent = cpStats
	c2.Parent = cpStats
	cpMult.TextColor3 = C.Accent
	ui.cpReward, ui.cpMult = cpReward, cpMult
	local cpBar, setCpBar = Components.progressBar()
	cpBar.LayoutOrder = 5
	cpBar.Size = UDim2.fromOffset(460, 3)
	cpBar.Parent = cPanel
	ui.setCpBar = setCpBar
	local buttons = make("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = 6,
		Parent = cPanel,
	}, { Components.list(Enum.FillDirection.Horizontal, S.M) })
	ui.extractButton = Components.button("EXTRACT", "Primary", { LayoutOrder = 1, Parent = buttons })
	ui.continueButton = Components.button("CONTINUE", "Secondary", { LayoutOrder = 2, Parent = buttons })
	ui.cpStatus = text("Eyebrow", "", { LayoutOrder = 7, Parent = cPanel })

	-- RESULTADOS (centro)
	ui.results = Components.fadeGroup({
		Name = "Results",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = root,
	})
	local rPanel = Components.panel({ Parent = ui.results })
	Components.list(Enum.FillDirection.Vertical, S.M).Parent = rPanel
	text("Eyebrow", "RIDE LOG", { LayoutOrder = 1, Parent = rPanel, TextColor3 = C.Accent })
	ui.resultsTitle = text("Title", "", { LayoutOrder = 2, Parent = rPanel })
	ui.resultsList = make("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = 3,
		Parent = rPanel,
	}, { Components.list(Enum.FillDirection.Vertical, S.XS) })

	-- TOAST (avisos curtos: eliminado, extraído, andar concluído)
	ui.toast = Components.fadeGroup({
		Name = "Toast",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.22),
		Parent = root,
	})
	local toastPanel = Components.panel({ Parent = ui.toast })
	Components.list(Enum.FillDirection.Vertical, S.XS, Enum.HorizontalAlignment.Center).Parent = toastPanel
	ui.toastEyebrow = text("Eyebrow", "", { LayoutOrder = 1, Parent = toastPanel })
	ui.toastTitle = text("Title", "", { LayoutOrder = 2, Parent = toastPanel })
	ui.toastPanel = toastPanel

	applyScale(root, uiScale)
	return gui
end

-- Toast ----------------------------------------------------------------------

local toastToken = 0
local function showToast(eyebrow: string, title: string, danger: boolean?, seconds: number?)
	toastToken += 1
	local token = toastToken
	ui.toastEyebrow.Text = eyebrow
	ui.toastTitle.Text = title
	ui.toastTitle.TextColor3 = if danger then C.Danger else C.Text
	local stroke = ui.toastPanel:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = if danger then C.Danger else C.Stroke
	end
	Components.setShown(ui.toast, true)
	task.delay(seconds or 3, function()
		if token == toastToken then
			Components.setShown(ui.toast, false)
		end
	end)
end

-- Renderização por estado ----------------------------------------------------------

local REASONS: { [string]: string } = {
	Moved = "YOU MOVED.",
	Fell = "YOU FELL.",
	Lava = "TOO HOT.",
	Died = "YOU DIDN'T MAKE IT.",
}

local function isPlaying(): boolean
	local p = StateController.Personal
	return p.InRun == true and p.Alive == true
end

local function renderProfile()
	local level = player:GetAttribute("Level")
	local coins = player:GetAttribute("Coins")
	ui.profileLevel.Text = Theme.pad2(if typeof(level) == "number" then level else 1)
	ui.profileCoins.Text = `{if typeof(coins) == "number" then coins else 0} COINS`
end

local function renderPersonal()
	local p = StateController.Personal
	ui.streak.Text = string.format("x%.1f", p.Multiplier or 1)
	ui.reward.Text = "+" .. tostring(p.PendingCoins or 0)
	ui.cpReward.Text = "+" .. tostring(p.PendingCoins or 0)
	ui.cpMult.Text = string.format("x%.1f", p.Multiplier or 1)

	local chosen = p.Choice
	local canChoose = isPlaying() and chosen == nil
	ui.extractButton.setEnabled(canChoose)
	ui.continueButton.setEnabled(canChoose)
	if chosen == "Extract" then
		ui.cpStatus.Text = "EXTRACTING AT THE NEXT STOP"
	elseif chosen == "Continue" then
		ui.cpStatus.Text = "RIDING ON — WAITING FOR OTHERS"
	else
		ui.cpStatus.Text = ""
	end
end

local function renderResults(snapshot: { [string]: any })
	for _, child in ui.resultsList:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	local results = snapshot.Results
	if typeof(results) ~= "table" then
		return
	end
	for i, entry in results do
		if i > 6 then
			break
		end
		local outcome = tostring(entry.Outcome or "")
		local row = make("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = i,
			Parent = ui.resultsList,
		}, { Components.list(Enum.FillDirection.Horizontal, S.L) })
		text("Body", Theme.pad2(i), { FontFace = Theme.Font.Mono, TextColor3 = C.TextMuted, LayoutOrder = 1, Parent = row })
		text("Body", tostring(entry.Name), { LayoutOrder = 2, Size = UDim2.fromOffset(220, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = row })
		text("Body", `FLOOR {Theme.pad2(entry.FloorsCleared or 0)}`, { FontFace = Theme.Font.Mono, LayoutOrder = 3, Parent = row })
		text("Eyebrow", string.upper(outcome), {
			LayoutOrder = 4,
			TextColor3 = if outcome == "Eliminated" then C.Danger else C.Accent,
			Parent = row,
		})
	end
end

local function render(snapshot: { [string]: any })
	local state = snapshot.State
	local inMatch = state ~= "Lobby" and state ~= "Countdown"
	local playing = isPlaying()

	if state ~= lastState then
		phaseDuration = math.max(0.001, StateController.timeLeft())
	end

	-- Visibilidade contextual
	Components.setShown(ui.profile, not inMatch)
	Components.setShown(ui.lobby, not inMatch)
	Components.setShown(ui.floor, inMatch and state ~= "MatchEnded")
	Components.setShown(ui.run, inMatch and state ~= "MatchEnded")
	Components.setShown(ui.transition, state == "Elevator")
	Components.setShown(ui.intro, state == "FloorIntro")
	Components.setShown(ui.objective, state == "FloorActive")
	Components.setShown(ui.checkpoint, state == "Checkpoint" and playing)
	Components.setShown(ui.results, state == "MatchEnded")

	-- Conteúdo
	ui.survivors.Text = `{Theme.pad2(snapshot.Survivors or 0)}/{Theme.pad2(snapshot.Participants or 0)}`
	ui.floorNumber.Text = if state == "Elevator" then "--" else Theme.pad2(snapshot.Floor or 0)
	ui.floorName.Text = snapshot.FloorName or ""

	if state == "Lobby" then
		ui.lobbyEyebrow.Text = "NEXT ELEVATOR"
		ui.lobbyStatus.Text = Theme.Copy.Waiting
	elseif state == "Countdown" then
		ui.lobbyEyebrow.Text = "NEXT ELEVATOR"
		ui.lobbyStatus.Text = `{#Players:GetPlayers()} PASSENGER(S) ABOARD SOON`
	end

	if state == "FloorIntro" then
		ui.introEyebrow.Text = `FLOOR {Theme.pad2(snapshot.Floor or 0)}`
		ui.introRule.Text = snapshot.Rule or ""
		ui.introObjective.Text = snapshot.Objective or ""
	end

	if state == "FloorActive" then
		ui.rule.Text = snapshot.FloorName or ""
		ui.objectiveText.Text = snapshot.Objective or ""
		local swatch = snapshot.ObjectiveSwatch
		ui.swatch.Visible = typeof(swatch) == "Color3"
		if typeof(swatch) == "Color3" then
			ui.swatch.BackgroundColor3 = swatch
		end
	end

	if state == "FloorResults" and state ~= lastState then
		if snapshot.Cleared then
			showToast(`FLOOR {Theme.pad2(snapshot.Floor or 0)}`, "CLEARED", false, 3)
		else
			showToast(`FLOOR {Theme.pad2(snapshot.Floor or 0)}`, "NO SURVIVORS", true, 3)
		end
	end

	if state == "Checkpoint" then
		ui.cpTitle.Text = `FLOOR {Theme.pad2(snapshot.Floor or 0)} CLEARED`
		if playing and state ~= lastState and UserInputService.GamepadEnabled then
			GuiService.SelectedObject = ui.extractButton.Instance
		end
	elseif lastState == "Checkpoint" then
		GuiService.SelectedObject = nil
	end

	if state == "MatchEnded" then
		local p = StateController.Personal
		ui.resultsTitle.Text = `REACHED FLOOR {Theme.pad2(p.FloorsCleared or 0)}`
		renderResults(snapshot)
	end

	lastState = state
	renderPersonal()
end

-- Timers (atualizados localmente a partir de EndsAt do servidor)
local function tickTimers()
	local snapshot = StateController.Snapshot
	local left = StateController.timeLeft()
	local alpha = left / phaseDuration
	local state = snapshot.State
	if state == "Countdown" then
		ui.lobbyTimer.Text = Theme.clock(left)
	elseif state == "Lobby" then
		ui.lobbyTimer.Text = "--:--"
	elseif state == "FloorActive" then
		ui.timer.Text = Theme.clock(left)
		ui.timer.TextColor3 = if left <= 5 then C.Danger else C.Accent
		ui.setObjectiveBar(alpha)
	elseif state == "Checkpoint" then
		ui.setCpBar(alpha)
	elseif state == "Elevator" then
		ui.transitionNumber.Text = if left > 2 then tostring(math.random(10, 99)) else Theme.pad2((snapshot.Floor or 0) + 1)
	end
end

-- Entrada (teclado / controle / toque) ------------------------------------------

local function choose(choice: string)
	if StateController.Snapshot.State ~= "Checkpoint" or not isPlaying() then
		return
	end
	if StateController.Personal.Choice ~= nil then
		return
	end
	StateController.send("CheckpointChoice", { Choice = choice })
end

local function refreshHints()
	local last = UserInputService:GetLastInputType()
	local gamepad = last.Name:find("Gamepad") ~= nil
	local touch = last == Enum.UserInputType.Touch
	ui.extractButton.setHint(if gamepad then "X" elseif touch then "" else "1")
	ui.continueButton.setHint(if gamepad then "Y" elseif touch then "" else "2")
end

local function bindCheckpointActions()
	ContextActionService:BindAction("ElevatorExtract", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			choose("Extract")
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.One, Enum.KeyCode.ButtonX)
	ContextActionService:BindAction("ElevatorContinue", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			choose("Continue")
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.Two, Enum.KeyCode.ButtonY)
end

-- Ciclo de vida --------------------------------------------------------------

function InterfaceController.init()
	local gui = build()
	gui.Parent = player:WaitForChild("PlayerGui")

	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			applyScale(InterfaceController.Root, ui.uiScale)
		end)
	end

	ui.extractButton.Activated:Connect(function()
		choose("Extract")
	end)
	ui.continueButton.Activated:Connect(function()
		choose("Continue")
	end)
	bindCheckpointActions()
	refreshHints()
	UserInputService.LastInputTypeChanged:Connect(refreshHints)

	StateController.Changed:Connect(render)
	StateController.PersonalChanged:Connect(function()
		renderPersonal()
		render(StateController.Snapshot)
	end)
	StateController.Notice:Connect(function(payload)
		if payload.Type == "Eliminated" then
			showToast("ELIMINATED", REASONS[payload.Reason] or "ELIMINATED.", true, 3.5)
		elseif payload.Type == "Extracted" then
			showToast("EXTRACTED", `+{payload.Coins or 0} COINS SECURED`, false, 3.5)
		end
	end)

	for _, attr in { "Level", "Coins" } do
		player:GetAttributeChangedSignal(attr):Connect(renderProfile)
	end
	renderProfile()
	render(StateController.Snapshot)
end

function InterfaceController.start()
	while true do
		tickTimers()
		task.wait(0.1)
	end
end

-- Usado por outros controllers para posicionar elementos dentro do HUD.
function InterfaceController.getRoot(): Frame
	return InterfaceController.Root
end

-- Progressão para exibição futura (barra de XP no lobby).
InterfaceController.levelProgress = function(): (number, number, number)
	local xp = player:GetAttribute("XP")
	return Progression.levelFromXP(if typeof(xp) == "number" then xp else 0)
end

return InterfaceController

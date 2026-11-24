--!strict
-- Espectador: quem foi eliminado/extraído (ou entrou no meio) assiste os sobreviventes.
-- Troca de alvo: botões na tela, Q/E no teclado, L1/R1 no controle.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Theme = require(ReplicatedStorage:WaitForChild("Shared").UI.Theme)
local Components = require(script.Parent.Parent.UI.Components)
local StateController = require(script.Parent.StateController)
local InterfaceController = require(script.Parent.InterfaceController)

local player = Players.LocalPlayer
local S = Theme.Space

local SPECTATE_STATES = {
	Elevator = true,
	FloorIntro = true,
	FloorActive = true,
	FloorResults = true,
	Checkpoint = true,
	Extraction = true,
}

local SpectatorController = {}

local bar: CanvasGroup
local nameLabel: TextLabel
local targetIndex = 1
local spectating = false

local function targets(): { Player }
	local list = {}
	local ids = StateController.Snapshot.AliveUserIds
	if typeof(ids) ~= "table" then
		return list
	end
	for _, id in ids do
		local p = Players:GetPlayerByUserId(id)
		if p and p ~= player then
			table.insert(list, p)
		end
	end
	return list
end

local function ownHumanoid(): Humanoid?
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function apply()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local list = targets()
	if not spectating or #list == 0 then
		local own = ownHumanoid()
		if own then
			camera.CameraSubject = own
		end
		Components.setShown(bar, false)
		return
	end
	targetIndex = ((targetIndex - 1) % #list) + 1
	local target = list[targetIndex]
	local humanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		camera.CameraSubject = humanoid
	end
	nameLabel.Text = string.upper(target.DisplayName)
	Components.setShown(bar, true)
end

local function cycle(step: number)
	if not spectating then
		return
	end
	targetIndex += step
	apply()
end

local function evaluate()
	local snapshot = StateController.Snapshot
	local personal = StateController.Personal
	local playing = personal.InRun == true and personal.Alive == true
	local should = SPECTATE_STATES[snapshot.State] == true and not playing
	if should ~= spectating then
		spectating = should
		targetIndex = 1
	end
	apply()
end

function SpectatorController.init()
	local root = InterfaceController.getRoot()
	bar = Components.fadeGroup({
		Name = "Spectator",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		Parent = root,
	})
	local panel = Components.panel({ Parent = bar })
	local layout = Components.list(Enum.FillDirection.Horizontal, S.M)
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = panel

	local prev = Components.button("<", "Secondary", { LayoutOrder = 1, Size = UDim2.fromOffset(Theme.MinTouchTarget, Theme.MinTouchTarget) })
	prev.Instance.Parent = panel
	local info = Components.make("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = 2,
		Parent = panel,
	}, { Components.list(Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center) })
	Components.text("Eyebrow", "SPECTATING", { LayoutOrder = 1, Parent = info })
	nameLabel = Components.text("BodyLarge", "", {
		LayoutOrder = 2,
		Parent = info,
		FontFace = Theme.Font.BodyBold,
		Size = UDim2.fromOffset(220, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local nextButton = Components.button(">", "Secondary", { LayoutOrder = 3, Size = UDim2.fromOffset(Theme.MinTouchTarget, Theme.MinTouchTarget) })
	nextButton.Instance.Parent = panel

	prev.Activated:Connect(function()
		cycle(-1)
	end)
	nextButton.Activated:Connect(function()
		cycle(1)
	end)

	ContextActionService:BindAction("ElevatorSpectatePrev", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			cycle(-1)
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonL1)
	ContextActionService:BindAction("ElevatorSpectateNext", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			cycle(1)
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.E, Enum.KeyCode.ButtonR1)

	StateController.Changed:Connect(evaluate)
	StateController.PersonalChanged:Connect(evaluate)
	player.CharacterAdded:Connect(function()
		task.defer(evaluate)
	end)
end

return SpectatorController

--!strict
-- Biblioteca de componentes do ELEVATOR. Tudo usa Theme — nada de cor/fonte solta.
-- Linguagem visual: placas institucionais, cantos quase retos, traço fino,
-- números em display monoespaçado âmbar. Sem gradientes, sem neon.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(ReplicatedStorage:WaitForChild("Shared").UI.Theme)
local C = Theme.Color

local Components = {}

-- Cria uma instância com propriedades e filhos.
function Components.make(className: string, props: { [string]: any }?, children: { Instance }?): any
	local inst = Instance.new(className)
	if props then
		for key, value in props do
			if key ~= "Parent" then
				(inst :: any)[key] = value
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = inst
		end
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local make = Components.make

function Components.padding(all: number): UIPadding
	local u = UDim.new(0, all)
	return make("UIPadding", { PaddingTop = u, PaddingBottom = u, PaddingLeft = u, PaddingRight = u })
end

function Components.list(direction: Enum.FillDirection, gap: number, align: Enum.HorizontalAlignment?): UIListLayout
	return make("UIListLayout", {
		FillDirection = direction,
		Padding = UDim.new(0, gap),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	})
end

-- Painel base: superfície Charcoal translúcida + traço Sage fino.
function Components.panel(props: { [string]: any }?): Frame
	local frame = make("Frame", {
		BackgroundColor3 = C.Surface,
		BackgroundTransparency = C.SurfaceTransparency,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.XY,
	}, {
		make("UICorner", { CornerRadius = Theme.Radius }),
		make("UIStroke", {
			Color = C.Stroke,
			Transparency = C.StrokeTransparency,
			Thickness = Theme.StrokeThickness,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
		Components.padding(Theme.Space.M),
	})
	if props then
		for key, value in props do
			(frame :: any)[key] = value
		end
	end
	return frame
end

export type TextStyle = "Eyebrow" | "Body" | "BodyLarge" | "Title" | "Display" | "Hero"

local STYLE: { [string]: { font: Font, size: number, color: Color3 } } = {
	Eyebrow = { font = Theme.Font.BodyBold, size = Theme.TextSize.Eyebrow, color = C.TextMuted },
	Body = { font = Theme.Font.Body, size = Theme.TextSize.Body, color = C.Text },
	BodyLarge = { font = Theme.Font.Body, size = Theme.TextSize.BodyLarge, color = C.Text },
	Title = { font = Theme.Font.TitleBold, size = Theme.TextSize.Title, color = C.Text },
	Display = { font = Theme.Font.Mono, size = Theme.TextSize.Display, color = C.Accent },
	Hero = { font = Theme.Font.TitleBold, size = Theme.TextSize.Hero, color = C.Text },
}

function Components.text(style: TextStyle, text: string, props: { [string]: any }?): TextLabel
	local s = STYLE[style]
	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		FontFace = s.font,
		TextSize = s.size,
		TextColor3 = s.color,
		Text = text,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = false,
		RichText = false,
	})
	if props then
		for key, value in props do
			(label :: any)[key] = value
		end
	end
	return label
end

-- Linha fina divisória.
function Components.divider(width: UDim?): Frame
	return make("Frame", {
		BackgroundColor3 = C.Stroke,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Size = UDim2.new(width or UDim.new(1, 0), UDim.new(0, 1)),
	})
end

-- Barra de progresso fina (timer). Retorna frame e função set(0..1).
function Components.progressBar(color: Color3?): (Frame, (number) -> ())
	local fill = make("Frame", {
		Name = "Fill",
		BackgroundColor3 = color or C.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	local track = make("Frame", {
		BackgroundColor3 = C.Stroke,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 3),
	}, { fill })
	local function set(alpha: number)
		fill.Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1)
	end
	return track, set
end

export type ButtonVariant = "Primary" | "Secondary" | "Danger"

local VARIANT: { [string]: { bg: Color3, bgT: number, text: Color3, stroke: Color3 } } = {
	Primary = { bg = C.Accent, bgT = 0, text = C.TextInverse, stroke = C.Accent },
	Secondary = { bg = C.Surface, bgT = 0.1, text = C.Text, stroke = C.Stroke },
	Danger = { bg = C.Danger, bgT = 0, text = C.Text, stroke = C.Danger },
}

-- Botão com estados: normal / hover / pressed / disabled / selected (gamepad).
-- `hint` mostra a tecla/botão do controle (ex.: "1", "X").
function Components.button(label: string, variant: ButtonVariant?, props: { [string]: any }?)
	local v = VARIANT[variant or "Secondary"]
	local hint = Components.text("Eyebrow", "", {
		Name = "Hint",
		TextColor3 = v.text,
		TextTransparency = 0.35,
		LayoutOrder = 2,
	})
	local text = Components.text("BodyLarge", label, {
		Name = "Label",
		FontFace = Theme.Font.BodyBold,
		TextColor3 = v.text,
		LayoutOrder = 1,
	})
	local stroke = make("UIStroke", {
		Color = v.stroke,
		Thickness = Theme.StrokeThickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	local scale = make("UIScale", { Scale = 1 })
	local button: TextButton = make("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = v.bg,
		BackgroundTransparency = v.bgT,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(220, Theme.MinTouchTarget),
		Selectable = true,
	}, {
		make("UICorner", { CornerRadius = Theme.Radius }),
		stroke,
		scale,
		Components.list(Enum.FillDirection.Horizontal, Theme.Space.S, Enum.HorizontalAlignment.Center),
		text,
		hint,
	})
	local layout = button:FindFirstChildOfClass("UIListLayout") :: UIListLayout
	layout.VerticalAlignment = Enum.VerticalAlignment.Center

	-- Contorno de seleção do gamepad
	button.SelectionImageObject = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		make("UIStroke", { Color = C.Text, Thickness = 2 }),
		make("UICorner", { CornerRadius = Theme.Radius }),
	})

	local hovering = false
	local enabled = true
	local function refresh()
		local target = if not enabled then 0.6 elseif hovering then math.max(0, v.bgT - 0.1) else v.bgT
		TweenService:Create(button, Theme.Motion.Fast, { BackgroundTransparency = target }):Play()
		text.TextTransparency = if enabled then 0 else 0.5
	end
	button.MouseEnter:Connect(function()
		hovering = true
		refresh()
	end)
	button.MouseLeave:Connect(function()
		hovering = false
		refresh()
	end)
	button.MouseButton1Down:Connect(function()
		if enabled then
			TweenService:Create(scale, Theme.Motion.Fast, { Scale = 0.96 }):Play()
		end
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, Theme.Motion.Fast, { Scale = 1 }):Play()
	end)

	if props then
		for key, value in props do
			(button :: any)[key] = value
		end
	end

	local api = {
		Instance = button,
		Activated = button.Activated,
	}
	function api.setEnabled(on: boolean)
		enabled = on
		button.Active = on
		button.Selectable = on
		refresh()
	end
	function api.setHint(value: string)
		hint.Text = value
		hint.Visible = value ~= ""
	end
	function api.setLabel(value: string)
		text.Text = value
	end
	function api.isEnabled(): boolean
		return enabled
	end
	api.setHint("")
	return api
end

-- Mostra/esconde com fade + leve deslocamento (via CanvasGroup).
function Components.fadeGroup(props: { [string]: any }?): CanvasGroup
	local group = make("CanvasGroup", {
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.XY,
	})
	if props then
		for key, value in props do
			(group :: any)[key] = value
		end
	end
	return group
end

function Components.setShown(group: CanvasGroup, shown: boolean)
	if shown then
		if not group.Visible then
			group.Visible = true
			group.GroupTransparency = 1
		end
		TweenService:Create(group, Theme.Motion.Base, { GroupTransparency = 0 }):Play()
	else
		if not group.Visible then
			return
		end
		local tween = TweenService:Create(group, Theme.Motion.Fast, { GroupTransparency = 1 })
		tween.Completed:Connect(function(state)
			if state == Enum.PlaybackState.Completed and group.GroupTransparency >= 0.99 then
				group.Visible = false
			end
		end)
		tween:Play()
	end
end

return Components

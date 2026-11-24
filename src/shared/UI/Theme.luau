--!strict
-- ELEVATOR Design Tokens — única fonte de cores, fontes, tamanhos e movimento.
-- Compartilhado: usado pela UI do cliente e por SurfaceGuis do mundo (painel do elevador).

local function hex(value: string): Color3
	return Color3.fromHex(value)
end

local Theme = {}

Theme.Palette = {
	Charcoal = hex("#252725"),
	OldIvory = hex("#D6CBB5"),
	DustySage = hex("#A3A18A"),
	WarningAmber = hex("#C77B55"),
	FogWhite = hex("#E7E2D7"),
	EmergencyRed = hex("#A83C38"),
}

local P = Theme.Palette

-- Papéis semânticos: componentes usam ISTO, não a paleta direta.
Theme.Color = {
	Surface = P.Charcoal,
	SurfaceTransparency = 0.12,
	Overlay = P.Charcoal,
	Text = P.FogWhite,
	TextMuted = P.DustySage,
	TextInverse = P.Charcoal,
	Accent = P.WarningAmber, -- números de display, destaque
	Danger = P.EmergencyRed,
	Stroke = P.DustySage,
	StrokeTransparency = 0.55,
	Paper = P.OldIvory, -- placas institucionais
}

-- Fontes. Space Grotesk / Inter não são garantidas no Roblox:
-- troque aqui quando houver as fontes oficiais (ex.: Font.new(assetId)).
Theme.Font = {
	Title = Font.fromEnum(Enum.Font.Montserrat),
	TitleBold = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold),
	Body = Font.fromEnum(Enum.Font.BuilderSans),
	BodyBold = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
	Mono = Font.fromEnum(Enum.Font.RobotoMono),
}

-- Tamanhos em pixels na resolução de referência (1280x720). O UIScale do HUD ajusta.
Theme.TextSize = {
	Eyebrow = 13, -- rótulos em caixa alta ("FLOOR", "SURVIVORS")
	Body = 18,
	BodyLarge = 22,
	Title = 30,
	Display = 44, -- números grandes (andar, timer)
	Hero = 72, -- intro do andar
}

Theme.Space = {
	XS = 4,
	S = 8,
	M = 12,
	L = 20,
	XL = 32,
}

Theme.Radius = UDim.new(0, 2) -- cantos quase retos: nada de cards arredondados
Theme.StrokeThickness = 1
Theme.MinTouchTarget = 56 -- altura mínima de botão na referência

Theme.ReferenceResolution = Vector2.new(1280, 720)
Theme.MinScale = 0.72 -- garante texto legível em celular
Theme.MaxScale = 1.6

-- Movimento: curto e mecânico, como um painel industrial.
Theme.Motion = {
	Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Base = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Slow = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

-- Frases ambientais da marca.
Theme.Copy = {
	Tagline = "NO FLOOR IS THE SAME.",
	Waiting = "PLEASE WAIT",
	Unknown = "DESTINATION UNKNOWN",
	SystemActive = "SYSTEM ACTIVE",
	NotFound = "FLOOR NOT FOUND",
	Established = "EST. 1999",
}

function Theme.pad2(n: number): string
	return string.format("%02d", math.max(0, math.floor(n)))
end

function Theme.clock(seconds: number): string
	local s = math.max(0, math.ceil(seconds))
	return string.format("%02d:%02d", s // 60, s % 60)
end

return Theme

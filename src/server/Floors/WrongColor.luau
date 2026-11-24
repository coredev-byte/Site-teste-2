--!strict
-- FLOOR 02 — WRONG COLOR
-- Uma cor é anunciada; as outras plataformas somem. Quem cai no vazio é eliminado
-- (o FloorService cuida da queda). Cada rodada dá menos tempo de reação.
-- Acessibilidade: cada plataforma mostra o NOME da cor, não só a cor.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("Shared").UI.Theme)
local Builders = require(script.Parent.Parent.World.Builders)

local P = Theme.Palette

-- Cores dessaturadas para combinar com a estética, mas bem distintas entre si.
local COLORS = {
	{ Name = "RED", Color = P.EmergencyRed },
	{ Name = "AMBER", Color = P.WarningAmber },
	{ Name = "SAGE", Color = P.DustySage },
	{ Name = "IVORY", Color = P.FogWhite },
	{ Name = "BLUE", Color = Color3.fromHex("#4F6D7A") },
	{ Name = "GREEN", Color = Color3.fromHex("#4E6B4A") },
}

local PAD_SIZE = 16
local GAP = 2
local COLS, ROWS = 3, 2

local REACTION_START = 5
local REACTION_STEP = 0.5
local REACTION_MIN = 2
local DROP_TIME = 2.5

local WrongColor = {}

WrongColor.Arena = { Size = Vector3.new(64, 28, 46), HasFloor = false }

local pads: { { part: Part, name: string } } = {}

local function makeLabel(pad: Part, text: string)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 20
	gui.LightInfluence = 0.4
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 0.3)
	label.Position = UDim2.fromScale(0, 0.35)
	label.Text = text
	label.TextScaled = true
	label.FontFace = Theme.Font.TitleBold
	label.TextColor3 = P.Charcoal
	label.TextTransparency = 0.35
	label.Parent = gui
	gui.Parent = pad
end

function WrongColor.setup(ctx: any)
	table.clear(pads)
	local origin: Vector3 = ctx.Origin
	local totalX = COLS * PAD_SIZE + (COLS - 1) * GAP
	local totalZ = ROWS * PAD_SIZE + (ROWS - 1) * GAP
	local i = 0
	for row = 0, ROWS - 1 do
		for col = 0, COLS - 1 do
			i += 1
			local entry = COLORS[i]
			local x = -totalX / 2 + PAD_SIZE / 2 + col * (PAD_SIZE + GAP)
			local z = -totalZ / 2 + PAD_SIZE / 2 + row * (PAD_SIZE + GAP)
			local pad = Builders.part({
				Name = "Pad_" .. entry.Name,
				Size = Vector3.new(PAD_SIZE, 1, PAD_SIZE),
				Position = origin + Vector3.new(x, -0.5, z),
				Color = entry.Color,
				Material = Enum.Material.SmoothPlastic,
				Parent = ctx.Arena,
			})
			makeLabel(pad, entry.Name)
			table.insert(pads, { part = pad, name = entry.Name })
		end
	end
end

function WrongColor.start(ctx: any)
	local thread = task.spawn(function()
		local round = 0
		while true do
			local reaction = math.max(REACTION_MIN, REACTION_START - round * REACTION_STEP)
			if ctx.timeLeft() < reaction + DROP_TIME + 0.5 then
				ctx.setObjective("Hold on. The floor is stable.")
				break
			end
			round += 1
			local pick = pads[ctx.Random:NextInteger(1, #pads)]
			local entry = COLORS[table.find(pads, pick) or 1]
			ctx.setObjective("Stand on " .. pick.name, entry.Color)
			ctx.fire({ Type = "ColorCall", Name = pick.name, Color = entry.Color, Reaction = reaction, Round = round })
			task.wait(reaction)

			for _, pad in pads do
				if pad ~= pick then
					pad.part.Transparency = 0.85
					pad.part.CanCollide = false
				end
			end
			task.wait(DROP_TIME)
			for _, pad in pads do
				pad.part.Transparency = 0
				pad.part.CanCollide = true
			end
			task.wait(1)
		end
	end)
	ctx.Maid:give(thread)
end

function WrongColor.stop(_ctx: any)
	table.clear(pads)
end

return WrongColor

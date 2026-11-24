--!strict
-- Geometria PLACEHOLDER gerada por código, para o jogo rodar antes dos assets finais.
-- Quando existirem modelos reais (Workspace.Elevator, ServerStorage.FloorTemplates.<Env>),
-- eles têm prioridade e nada daqui é usado.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("Shared").UI.Theme)
local P = Theme.Palette

local Builders = {}

export type ArenaOptions = {
	Size: Vector3?, -- interior (X, altura, Z)
	HasFloor: boolean?,
}

-- Cor de parede/chão por ambiente (liminal: bege, cinza, verde desbotado).
local ENV_STYLE: { [string]: { wall: Color3, floor: Color3, floorMaterial: Enum.Material } } = {
	Office = { wall = P.OldIvory, floor = P.DustySage, floorMaterial = Enum.Material.Carpet },
	Hallway = { wall = P.OldIvory, floor = Color3.fromHex("#8C8670"), floorMaterial = Enum.Material.Carpet },
	Pool = { wall = P.FogWhite, floor = P.FogWhite, floorMaterial = Enum.Material.Ceramic },
	Warehouse = { wall = Color3.fromHex("#6E6C63"), floor = Color3.fromHex("#5A5A55"), floorMaterial = Enum.Material.Concrete },
	Storage = { wall = Color3.fromHex("#7C7A6B"), floor = Color3.fromHex("#55564F"), floorMaterial = Enum.Material.Concrete },
}

function Builders.part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	p.CastShadow = true
	for key, value in props do
		(p :: any)[key] = value
	end
	return p
end

-- Luz fluorescente de teto: SurfaceLight apontando para baixo.
function Builders.ceilingLight(parent: Instance, position: Vector3, brightness: number?): Part
	local panel = Builders.part({
		Name = "FluorescentPanel",
		Size = Vector3.new(6, 0.2, 2),
		Position = position,
		Color = P.FogWhite,
		Material = Enum.Material.Neon,
		CastShadow = false,
		Parent = parent,
	})
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Bottom
	light.Angle = 110
	light.Range = 22
	light.Brightness = brightness or 1.6
	light.Color = Color3.fromHex("#F2EBDD")
	light.Shadows = true
	light.Parent = panel
	return panel
end

-- Sala retangular: chão opcional, 4 paredes, teto e luzes. Retorna o Model.
-- O Model contém "SpawnArea" (BasePart invisível) usada para posicionar jogadores.
function Builders.arena(environment: string, origin: Vector3, options: ArenaOptions?): Model
	local opts = options or {}
	local size = opts.Size or Vector3.new(80, 24, 80)
	local style = ENV_STYLE[environment] or ENV_STYLE.Office
	local wallThickness = 2

	local model = Instance.new("Model")
	model.Name = "Arena_" .. environment

	if opts.HasFloor ~= false then
		Builders.part({
			Name = "Floor",
			Size = Vector3.new(size.X, 1, size.Z),
			Position = origin + Vector3.new(0, -0.5, 0),
			Color = style.floor,
			Material = style.floorMaterial,
			Parent = model,
		})
	end

	local half = size / 2
	local walls = {
		{ Vector3.new(size.X + wallThickness * 2, size.Y, wallThickness), Vector3.new(0, half.Y, half.Z + wallThickness / 2) },
		{ Vector3.new(size.X + wallThickness * 2, size.Y, wallThickness), Vector3.new(0, half.Y, -half.Z - wallThickness / 2) },
		{ Vector3.new(wallThickness, size.Y, size.Z), Vector3.new(half.X + wallThickness / 2, half.Y, 0) },
		{ Vector3.new(wallThickness, size.Y, size.Z), Vector3.new(-half.X - wallThickness / 2, half.Y, 0) },
	}
	for i, w in walls do
		Builders.part({
			Name = "Wall" .. i,
			Size = w[1],
			Position = origin + w[2],
			Color = style.wall,
			Parent = model,
		})
	end

	Builders.part({
		Name = "Ceiling",
		Size = Vector3.new(size.X + wallThickness * 2, 1, size.Z + wallThickness * 2),
		Position = origin + Vector3.new(0, size.Y + 0.5, 0),
		Color = P.FogWhite,
		Parent = model,
	})

	-- grade de luzes
	local step = 20
	for x = -half.X + step / 2, half.X - step / 2, step do
		for z = -half.Z + step / 2, half.Z - step / 2, step do
			Builders.ceilingLight(model, origin + Vector3.new(x, size.Y - 0.2, z))
		end
	end

	local spawnArea = Builders.part({
		Name = "SpawnArea",
		Size = Vector3.new(math.min(20, size.X - 4), 1, math.min(20, size.Z - 4)),
		Position = origin + Vector3.new(0, 3, 0),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = model,
	})
	model.PrimaryPart = spawnArea

	return model
end

-- Cabine do elevador placeholder. Peças com os nomes que o ElevatorService procura:
--   Inside (BasePart invisível = área de embarque), DoorLeft, DoorRight, Display (SurfaceGui).
function Builders.elevator(origin: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "Elevator"
	local size = Vector3.new(14, 12, 14)
	local half = size / 2
	local metal = Color3.fromHex("#8E8F88")

	Builders.part({
		Name = "Floor",
		Size = Vector3.new(size.X, 1, size.Z),
		Position = origin + Vector3.new(0, -0.5, 0),
		Color = Color3.fromHex("#3B3D39"),
		Material = Enum.Material.DiamondPlate,
		Parent = model,
	})
	Builders.part({
		Name = "Ceiling",
		Size = Vector3.new(size.X, 1, size.Z),
		Position = origin + Vector3.new(0, size.Y + 0.5, 0),
		Color = metal,
		Material = Enum.Material.Metal,
		Parent = model,
	})
	for i, w in {
		{ Vector3.new(1, size.Y, size.Z), Vector3.new(half.X + 0.5, half.Y, 0) },
		{ Vector3.new(1, size.Y, size.Z), Vector3.new(-half.X - 0.5, half.Y, 0) },
		{ Vector3.new(size.X, size.Y, 1), Vector3.new(0, half.Y, -half.Z - 0.5) },
	} do
		Builders.part({
			Name = "Wall" .. i,
			Size = w[1],
			Position = origin + w[2],
			Color = metal,
			Material = Enum.Material.Metal,
			Reflectance = 0.08,
			Parent = model,
		})
	end

	-- Portas na face +Z
	local doorSize = Vector3.new(size.X / 2, size.Y, 0.6)
	for _, side in { -1, 1 } do
		Builders.part({
			Name = if side < 0 then "DoorLeft" else "DoorRight",
			Size = doorSize,
			Position = origin + Vector3.new(side * size.X / 4, half.Y, half.Z + 0.3),
			Color = Color3.fromHex("#A7A8A1"),
			Material = Enum.Material.Metal,
			Reflectance = 0.12,
			Parent = model,
		})
	end

	Builders.ceilingLight(model, origin + Vector3.new(0, size.Y - 0.2, 0), 1.3)

	-- Display de andar acima da porta (por dentro)
	local displayPart = Builders.part({
		Name = "DisplayPanel",
		Size = Vector3.new(4, 1.4, 0.2),
		Position = origin + Vector3.new(0, size.Y - 1.6, half.Z - 0.2),
		Color = P.Charcoal,
		Parent = model,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Display"
	gui.Face = Enum.NormalId.Front -- Front = -Z: voltada para dentro da cabine
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	gui.LightInfluence = 0
	gui.Parent = displayPart
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.FontFace = Theme.Font.Mono
	label.TextScaled = true
	label.TextColor3 = Theme.Color.Accent
	label.Text = "--"
	label.Parent = gui

	local inside = Builders.part({
		Name = "Inside",
		Size = Vector3.new(size.X - 4, 1, size.Z - 4),
		Position = origin + Vector3.new(0, 3, 0),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = model,
	})
	model.PrimaryPart = inside

	return model
end

-- Ponto aleatório dentro de uma BasePart (no plano XZ), acima dela.
function Builders.randomPointIn(part: BasePart, rng: Random): CFrame
	local size = part.Size
	local offset = Vector3.new(rng:NextNumber(-0.5, 0.5) * size.X, 0, rng:NextNumber(-0.5, 0.5) * size.Z)
	return CFrame.new((part.CFrame * CFrame.new(offset)).Position + Vector3.new(0, 2, 0))
end

return Builders

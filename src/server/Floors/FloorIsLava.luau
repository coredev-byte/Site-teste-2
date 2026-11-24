--!strict
-- FLOOR 03 — THE FLOOR IS LAVA
-- O calor sobe do chão; plataformas em alturas variadas permitem escalar.
-- Eliminação por posição dos pés (não usa Touched, que é pouco confiável).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Theme = require(ReplicatedStorage:WaitForChild("Shared").UI.Theme)
local Builders = require(script.Parent.Parent.World.Builders)
local Characters = require(script.Parent.Parent.World.Characters)

local P = Theme.Palette

local ARENA = Vector3.new(70, 60, 70)
local PLATFORM_COUNT = 26
local MAX_RISE = 30 -- altura final da lava
local RISE_PORTION = 0.85 -- fração do tempo em que a lava sobe
local START_DELAY = 3

local FloorIsLava = {}

FloorIsLava.Arena = { Size = ARENA }

local lava: Part? = nil

function FloorIsLava.setup(ctx: any)
	local origin: Vector3 = ctx.Origin
	local rng: Random = ctx.Random

	-- Plataformas em "espiral" aproximada para sempre haver um caminho para cima.
	for i = 1, PLATFORM_COUNT do
		local height = 2 + (i / PLATFORM_COUNT) * (MAX_RISE + 8)
		local angle = i * 0.9 + rng:NextNumber(-0.2, 0.2)
		local radius = rng:NextNumber(10, ARENA.X / 2 - 8)
		local size = rng:NextNumber(6, 10)
		Builders.part({
			Name = "Platform" .. i,
			Size = Vector3.new(size, 1, size),
			Position = origin + Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius),
			Color = Color3.fromHex("#6E6C63"),
			Material = Enum.Material.Metal,
			Parent = ctx.Arena,
		})
	end

	local part = Builders.part({
		Name = "Lava",
		Size = Vector3.new(ARENA.X, 1, ARENA.Z),
		Position = origin + Vector3.new(0, -0.4, 0),
		Color = P.WarningAmber,
		Material = Enum.Material.Neon,
		Transparency = 0.15,
		CanCollide = false,
		CanQuery = false,
		CastShadow = false,
		Parent = ctx.Arena,
	})
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Top
	light.Color = P.WarningAmber
	light.Range = 18
	light.Brightness = 1.2
	light.Parent = part
	lava = part
end

function FloorIsLava.start(ctx: any)
	local part = lava
	if not part then
		return
	end
	local origin: Vector3 = ctx.Origin
	local duration = ctx.timeLeft()
	local riseTime = math.max(1, duration * RISE_PORTION - START_DELAY)
	local elapsed = -START_DELAY

	ctx.setObjective("Climb. The heat rises in " .. START_DELAY .. "s.")

	ctx.Maid:give(RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed <= 0 then
			return
		end
		local level = math.min(1, elapsed / riseTime) * MAX_RISE
		part.Size = Vector3.new(ARENA.X, level + 1, ARENA.Z)
		part.Position = origin + Vector3.new(0, (level + 1) / 2 - 0.9, 0)
		local surfaceY = origin.Y + level

		for _, player in ctx.getAlive() do
			local feet = Characters.feetY(player)
			if feet and feet < surfaceY - 0.2 then
				ctx.eliminate(player, "Lava")
			end
		end
	end))
end

function FloorIsLava.stop(_ctx: any)
	lava = nil
end

return FloorIsLava

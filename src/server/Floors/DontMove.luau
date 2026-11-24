--!strict
-- FLOOR 01 — DON'T MOVE
-- Após um curto aviso, qualquer deslocamento além da tolerância elimina.
-- A posição é lida no servidor; a tolerância absorve latência e física.

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Characters = require(script.Parent.Parent.World.Characters)

local GRACE = 2 -- segundos para parar após a intro
local TOLERANCE_XZ = 1.6 -- studs
local TOLERANCE_Y = 2.5 -- pulos

local DontMove = {}

DontMove.Arena = { Size = Vector3.new(40, 16, 120) } -- corredor longo

function DontMove.start(ctx: any)
	local anchors: { [Player]: Vector3 } = {}
	local armed = false
	local armAt = Workspace:GetServerTimeNow() + GRACE

	ctx.setObjective("Find your spot. Freeze in " .. GRACE .. "s.")

	ctx.Maid:give(RunService.Heartbeat:Connect(function()
		if not armed then
			if Workspace:GetServerTimeNow() >= armAt then
				armed = true
				ctx.setObjective("DON'T. MOVE.")
				ctx.fire({ Type = "Armed" })
			else
				return
			end
		end
		for _, player in ctx.getAlive() do
			local root = Characters.root(player)
			if root then
				local anchor = anchors[player]
				if not anchor then
					anchors[player] = root.Position
				else
					local delta = root.Position - anchor
					local horizontal = Vector3.new(delta.X, 0, delta.Z).Magnitude
					if horizontal > TOLERANCE_XZ or math.abs(delta.Y) > TOLERANCE_Y then
						ctx.eliminate(player, "Moved")
					end
				end
			end
		end
	end))
end

return DontMove

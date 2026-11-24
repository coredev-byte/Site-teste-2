--!strict
-- Helpers de personagem usados por vários serviços.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared").Config)

local Characters = {}

function Characters.humanoid(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		return humanoid
	end
	return nil
end

function Characters.root(player: Player): BasePart?
	local character = player.Character
	if not character or not Characters.humanoid(player) then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

-- Altura dos pés (aprox.) — usado em checagens como lava/água.
function Characters.feetY(player: Player): number?
	local root = Characters.root(player)
	local humanoid = Characters.humanoid(player)
	if not root or not humanoid then
		return nil
	end
	return root.Position.Y - root.Size.Y / 2 - humanoid.HipHeight
end

function Characters.teleport(player: Player, cframe: CFrame)
	local character = player.Character
	if character and Characters.humanoid(player) then
		character:PivotTo(cframe)
	end
end

function Characters.setMovement(player: Player, enabled: boolean)
	local humanoid = Characters.humanoid(player)
	if not humanoid then
		return
	end
	humanoid.WalkSpeed = if enabled then Config.World.DefaultWalkSpeed else 0
	humanoid.UseJumpPower = false
	humanoid.JumpHeight = if enabled then Config.World.DefaultJumpHeight else 0
end

-- Volta ao lobby: usa Workspace.Lobby.Spawn se existir; senão respawna (SpawnLocation).
function Characters.sendToLobby(player: Player)
	if player.Parent ~= Players then
		return
	end
	local lobby = Workspace:FindFirstChild("Lobby")
	local spawnPart = lobby and lobby:FindFirstChild("Spawn")
	if spawnPart and spawnPart:IsA("BasePart") and Characters.humanoid(player) then
		Characters.setMovement(player, true)
		Characters.teleport(player, spawnPart.CFrame + Vector3.new(0, 4, 0))
	else
		player:LoadCharacter()
	end
end

return Characters

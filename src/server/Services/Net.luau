--!strict
-- Cria os remotes e centraliza envio/recebimento com validação e rate limit.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local Config = require(Shared.Config)

type ActionHandler = (player: Player, payload: { [string]: any }) -> ()

local Net = {}

local remotes: { [string]: RemoteEvent } = {}
local handlers: { [string]: ActionHandler } = {}
local buckets: { [Player]: { tokens: number, last: number } } = {}

local function allow(player: Player): boolean
	local now = os.clock()
	local rate = Config.Net.ActionsPerSecond
	local bucket = buckets[player]
	if not bucket then
		bucket = { tokens = rate, last = now }
		buckets[player] = bucket
	end
	bucket.tokens = math.min(rate, bucket.tokens + (now - bucket.last) * rate)
	bucket.last = now
	if bucket.tokens < 1 then
		return false
	end
	bucket.tokens -= 1
	return true
end

function Net.init()
	local folder = ReplicatedStorage:FindFirstChild(Remotes.FolderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = Remotes.FolderName
		folder.Parent = ReplicatedStorage
	end
	for _, name in Remotes.Names do
		local remote = folder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
		remotes[name] = remote :: RemoteEvent
	end

	remotes.PlayerAction.OnServerEvent:Connect(function(player: Player, action: unknown, payload: unknown)
		-- Nunca confiar no cliente: tipos, ação conhecida, rate limit.
		if typeof(action) ~= "string" or not allow(player) then
			return
		end
		local handler = handlers[action]
		if not handler then
			return
		end
		local data: { [string]: any } = if typeof(payload) == "table" then payload :: any else {}
		local ok, err = pcall(handler, player, data)
		if not ok then
			warn(`[Net] action {action} from {player.Name} failed: {err}`)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		buckets[player] = nil
	end)
end

function Net.onAction(action: string, handler: ActionHandler)
	assert(Remotes.Actions[action], "unknown action " .. action)
	handlers[action] = handler
end

function Net.fireAll(name: string, payload: any)
	local remote = remotes[name]
	if remote then
		remote:FireAllClients(payload)
	end
end

function Net.fire(player: Player, name: string, payload: any)
	local remote = remotes[name]
	if remote and player.Parent == Players then
		remote:FireClient(player, payload)
	end
end

return Net

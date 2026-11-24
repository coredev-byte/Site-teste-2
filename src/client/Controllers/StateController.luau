--!strict
-- Recebe o estado do servidor e o expõe para o resto do cliente via Signals.
-- Nenhuma outra parte do cliente deve escutar remotes diretamente.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local Signal = require(Shared.Util.Signal)

local StateController = {}

StateController.Snapshot = { State = "Lobby", Floor = 0, Survivors = 0, Participants = 0, AliveUserIds = {} } :: { [string]: any }
StateController.Personal = { Type = "Run", InRun = false, Alive = false, Streak = 0, Multiplier = 1, PendingCoins = 0 } :: { [string]: any }

StateController.Changed = Signal.new() -- (snapshot, previousState)
StateController.PersonalChanged = Signal.new() -- (personal)
StateController.Notice = Signal.new() -- (payload) Eliminated / Extracted / Results
StateController.FloorEvent = Signal.new() -- (payload)

local actionRemote: RemoteEvent? = nil

function StateController.init()
	local gameState = Remotes.waitFor("GameState")
	local uiUpdate = Remotes.waitFor("UIUpdate")
	local floorEvent = Remotes.waitFor("FloorEvent")
	actionRemote = Remotes.waitFor("PlayerAction")

	gameState.OnClientEvent:Connect(function(snapshot: any)
		if typeof(snapshot) ~= "table" then
			return
		end
		local previous = StateController.Snapshot.State
		StateController.Snapshot = snapshot
		StateController.Changed:Fire(snapshot, previous)
	end)

	uiUpdate.OnClientEvent:Connect(function(payload: any)
		if typeof(payload) ~= "table" then
			return
		end
		if payload.Type == "Run" then
			StateController.Personal = payload
			StateController.PersonalChanged:Fire(payload)
		else
			StateController.Notice:Fire(payload)
		end
	end)

	floorEvent.OnClientEvent:Connect(function(payload: any)
		if typeof(payload) == "table" then
			StateController.FloorEvent:Fire(payload)
		end
	end)
end

function StateController.start()
	-- Pede o estado atual (útil para quem entra no meio da partida).
	StateController.send("Ready")
end

function StateController.send(action: string, payload: { [string]: any }?)
	if actionRemote then
		actionRemote:FireServer(action, payload or {})
	end
end

function StateController.timeLeft(): number
	local endsAt = StateController.Snapshot.EndsAt
	if typeof(endsAt) ~= "number" then
		return 0
	end
	return math.max(0, endsAt - Workspace:GetServerTimeNow())
end

return StateController

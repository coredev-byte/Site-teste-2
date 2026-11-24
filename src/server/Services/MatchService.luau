--!strict
-- Máquina de estados da partida (GDD seção 10):
-- Lobby → Countdown → [Elevator → FloorIntro → FloorActive → FloorResults → (Checkpoint → Extraction)]* → MatchEnded
--
-- Regras de multiplayer:
--   * Ninguém entra no meio da rodada (quem chega assiste).
--   * Eliminados viram espectadores no lobby.
--   * Saída de jogador nunca trava a partida.
--   * Funciona com 1 jogador.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameTypes = require(Shared.GameTypes)
local Signal = require(Shared.Util.Signal)
local Net = require(script.Parent.Net)
local PlayerDataService = require(script.Parent.PlayerDataService)
local RewardService = require(script.Parent.RewardService)
local ElevatorService = require(script.Parent.ElevatorService)
local FloorService = require(script.Parent.FloorService)
local Characters = require(script.Parent.Parent.World.Characters)

type MatchState = GameTypes.MatchState
type FloorDefinition = GameTypes.FloorDefinition
type Run = RewardService.Run

local M = Config.Match

local MatchService = {}
MatchService.StateChanged = Signal.new()

local state: MatchState = "Lobby"
local fields: { [string]: any } = {} -- campos específicos da fase atual
local snapshot: { [string]: any } = { State = "Lobby", Floor = 0, Survivors = 0, Participants = 0, AliveUserIds = {} }
local runs: { [Player]: Run } = {}
local floorNumber = 0

local function now(): number
	return Workspace:GetServerTimeNow()
end

-- Jogadores ainda vivos no run (e ainda no servidor).
local function alivePlayers(): { Player }
	local list = {}
	for player, run in runs do
		if run.Alive and player.Parent == Players then
			table.insert(list, player)
		end
	end
	return list
end

local function countParticipants(): number
	local n = 0
	for _ in runs do
		n += 1
	end
	return n
end

local function publish()
	local alive = alivePlayers()
	local ids = {}
	for _, player in alive do
		table.insert(ids, player.UserId)
	end
	local snap: { [string]: any } = {
		State = state,
		Floor = floorNumber,
		Survivors = #alive,
		Participants = countParticipants(),
		AliveUserIds = ids,
	}
	for key, value in fields do
		snap[key] = value
	end
	snapshot = snap
	Net.fireAll("GameState", snap)
end

local function setState(newState: MatchState, newFields: { [string]: any }?)
	state = newState
	fields = newFields or {}
	publish()
	MatchService.StateChanged:Fire(newState)
end

local function sendPersonal(player: Player)
	local run = runs[player]
	local payload = {
		Type = "Run",
		InRun = run ~= nil,
		Alive = run ~= nil and run.Alive,
		Extracted = run ~= nil and run.Extracted,
		Streak = if run then run.Streak else 0,
		Multiplier = if run then RewardService.multiplier(run) else 1,
		PendingCoins = if run then run.PendingCoins else 0,
		FloorsCleared = if run then run.FloorsCleared else 0,
		Choice = if run then run.Choice else nil,
	}
	Net.fire(player, "UIUpdate", payload)
end

local function floorFields(def: FloorDefinition, endsAt: number): { [string]: any }
	return {
		EndsAt = endsAt,
		FloorId = def.Id,
		FloorName = def.Name,
		Rule = def.Rule,
		Objective = def.Objective,
		Environment = def.Environment,
	}
end

-- Eliminação --------------------------------------------------------------

local function eliminate(player: Player, reason: string)
	local run = runs[player]
	if not run or not run.Alive then
		return
	end
	run.Alive = false
	RewardService.forfeit(run)
	PlayerDataService.updateStats(player, function(stats)
		stats.Eliminations += 1
	end)
	Net.fire(player, "UIUpdate", { Type = "Eliminated", Reason = reason, Floor = floorNumber })
	sendPersonal(player)
	publish() -- atualiza contagem de sobreviventes para todos
	task.delay(M.EliminationReturnDelay, function()
		Characters.sendToLobby(player)
	end)
end

local function extract(player: Player)
	local run = runs[player]
	if not run or not run.Alive then
		return
	end
	run.Alive = false
	run.Extracted = true
	local amount = RewardService.bank(player, run, true)
	Net.fire(player, "UIUpdate", { Type = "Extracted", Coins = amount, Floor = floorNumber })
	sendPersonal(player)
	Characters.sendToLobby(player)
end

-- Fases --------------------------------------------------------------------

local function runLobby()
	floorNumber = 0
	setState("Lobby")
	ElevatorService.setDisplay("L")
	local countdownEnd: number? = nil
	while true do
		local count = #Players:GetPlayers()
		if count >= M.MinPlayersToStart then
			if not countdownEnd then
				countdownEnd = now() + M.LobbyCountdown
				setState("Countdown", { EndsAt = countdownEnd })
			elseif now() >= (countdownEnd :: number) then
				return
			end
		elseif countdownEnd then
			countdownEnd = nil
			setState("Lobby")
		end
		task.wait(0.25)
	end
end

local function runCheckpoint()
	for _, player in alivePlayers() do
		runs[player].Choice = nil
		sendPersonal(player)
	end
	local endsAt = now() + M.CheckpointDecisionTime
	setState("Checkpoint", { EndsAt = endsAt })

	while now() < endsAt do
		local waiting = false
		for _, player in alivePlayers() do
			if runs[player].Choice == nil then
				waiting = true
				break
			end
		end
		if not waiting then
			break
		end
		task.wait(0.2)
	end

	local extracted = 0
	for _, player in alivePlayers() do
		local run = runs[player]
		local choice = run.Choice or M.CheckpointDefaultChoice
		run.Choice = choice
		if choice == "Extract" then
			extract(player)
			extracted += 1
		else
			sendPersonal(player)
		end
	end

	if extracted > 0 then
		setState("Extraction", { EndsAt = now() + M.ExtractionDuration, Extracted = extracted })
		task.wait(M.ExtractionDuration)
	end
end

local function runMatch()
	runs = {}
	local participants = 0
	for _, player in Players:GetPlayers() do
		if participants >= M.MaxPlayers then
			break
		end
		if Characters.humanoid(player) then
			runs[player] = RewardService.newRun()
			participants += 1
		end
	end
	for player in runs do
		sendPersonal(player)
	end
	if participants == 0 then
		return
	end

	while #alivePlayers() > 0 do
		local nextFloor = floorNumber + 1
		local def = FloorService.choose(#alivePlayers())
		if not def then
			warn("[Match] nenhum andar disponível — encerrando partida.")
			break
		end

		-- Elevador
		ElevatorService.board(alivePlayers())
		setState("Elevator", { EndsAt = now() + M.ElevatorTransition })
		ElevatorService.runTransition(M.ElevatorTransition, nextFloor)
		floorNumber = nextFloor

		-- Andar
		FloorService.run(def, {
			getAlive = alivePlayers,
			eliminate = eliminate,
			onIntro = function(d, endsAt)
				setState("FloorIntro", floorFields(d, endsAt))
			end,
			onStart = function(d, endsAt)
				setState("FloorActive", floorFields(d, endsAt))
			end,
			onObjective = function(text, swatch)
				fields.Objective = text
				fields.ObjectiveSwatch = swatch
				publish()
			end,
		})

		-- Resultado do andar
		for _, player in alivePlayers() do
			RewardService.awardFloor(player, def, runs[player])
			sendPersonal(player)
		end
		local resultFields = floorFields(def, now() + M.FloorResults)
		resultFields.Cleared = #alivePlayers() > 0
		setState("FloorResults", resultFields)

		if #alivePlayers() == 0 then
			task.wait(M.FloorResults)
			break
		end
		-- Sobreviventes voltam ao elevador enquanto veem o resultado.
		ElevatorService.board(alivePlayers())
		task.wait(M.FloorResults)

		if floorNumber % M.CheckpointEvery == 0 then
			runCheckpoint()
		end
	end
end

local function endMatch()
	-- Quem ainda está vivo (ex.: sem andares disponíveis) leva o que acumulou.
	for _, player in alivePlayers() do
		local run = runs[player]
		RewardService.bank(player, run, false)
		run.Alive = false
	end

	local results = {}
	for player, run in runs do
		PlayerDataService.updateStats(player, function(stats)
			stats.MatchesPlayed += 1
			stats.BestFloor = math.max(stats.BestFloor, run.FloorsCleared)
		end)
		table.insert(results, {
			UserId = player.UserId,
			Name = player.DisplayName,
			FloorsCleared = run.FloorsCleared,
			Outcome = if run.Extracted then "Extracted" elseif run.CoinsEarned > 0 then "Survived" else "Eliminated",
		})
		Net.fire(player, "UIUpdate", {
			Type = "Results",
			FloorsCleared = run.FloorsCleared,
			CoinsEarned = run.CoinsEarned,
			Extracted = run.Extracted,
		})
	end
	table.sort(results, function(a, b)
		return a.FloorsCleared > b.FloorsCleared
	end)

	setState("MatchEnded", { EndsAt = now() + M.ResultsDuration, Results = results })
	task.wait(M.ResultsDuration)

	for player in runs do
		Characters.sendToLobby(player)
	end
	runs = {}
	for _, player in Players:GetPlayers() do
		sendPersonal(player)
	end
end

-- Ciclo de vida -------------------------------------------------------------

function MatchService.init()
	Net.onAction("Ready", function(player)
		Net.fire(player, "GameState", snapshot)
		sendPersonal(player)
	end)

	Net.onAction("CheckpointChoice", function(player, payload)
		if state ~= "Checkpoint" then
			return
		end
		local run = runs[player]
		if not run or not run.Alive or run.Choice ~= nil then
			return
		end
		local choice = payload.Choice
		if choice ~= "Continue" and choice ~= "Extract" then
			return
		end
		run.Choice = choice
		sendPersonal(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local run = runs[player]
		if run then
			run.Alive = false
			RewardService.forfeit(run)
			runs[player] = nil
			publish()
		end
	end)
end

function MatchService.start()
	while true do
		local ok, err = pcall(function()
			runLobby()
			runMatch()
			endMatch()
		end)
		if not ok then
			-- Nunca deixar o servidor preso: registra, devolve todos ao lobby e recomeça.
			warn("[Match] erro no ciclo da partida:", err)
			for player in runs do
				Characters.sendToLobby(player)
			end
			runs = {}
			task.wait(2)
		end
	end
end

function MatchService.getState(): MatchState
	return state
end

return MatchService

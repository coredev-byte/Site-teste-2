--!strict
-- Persistência com retry/backoff, lock de sessão simples, autosave e BindToClose.
-- Replica o resumo (Coins, XP, Level) como Attributes do Player — o cliente só lê.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Signal = require(Shared.Util.Signal)
local Progression = require(Shared.Util.Progression)

local SCHEMA_VERSION = 1

export type Stats = {
	BestFloor: number,
	MatchesPlayed: number,
	FloorsCleared: number,
	Extractions: number,
	Eliminations: number,
}

export type Profile = {
	Version: number,
	Coins: number,
	XP: number,
	Relics: { [string]: number },
	Stats: Stats,
}

local function defaultProfile(): Profile
	return {
		Version = SCHEMA_VERSION,
		Coins = 0,
		XP = 0,
		Relics = {},
		Stats = {
			BestFloor = 0,
			MatchesPlayed = 0,
			FloorsCleared = 0,
			Extractions = 0,
			Eliminations = 0,
		},
	}
end

-- Migração/reparo: preenche campos que faltam sem perder dados existentes.
local function migrate(raw: any): Profile
	local base = defaultProfile()
	if typeof(raw) ~= "table" then
		return base
	end
	for key, value in base :: any do
		if raw[key] == nil then
			raw[key] = value
		end
	end
	if typeof(raw.Stats) ~= "table" then
		raw.Stats = base.Stats
	else
		for key, value in base.Stats :: any do
			if raw.Stats[key] == nil then
				raw.Stats[key] = value
			end
		end
	end
	raw.Version = SCHEMA_VERSION
	return raw :: Profile
end

local PlayerDataService = {}
PlayerDataService.ProfileLoaded = Signal.new()

local store: DataStore? = nil
local profiles: { [Player]: Profile } = {}
local persist: { [Player]: boolean } = {} -- false = dados só em memória (falha/Studio sem API)

local function storeKey(player: Player): string
	return "player_" .. player.UserId
end

local function withRetry<T>(label: string, attempts: number, fn: () -> T): (boolean, T?)
	local lastErr: any = nil
	for attempt = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastErr = result
		warn(`[PlayerData] {label} attempt {attempt}/{attempts} failed: {result}`)
		if attempt < attempts then
			task.wait(math.min(2 ^ attempt, 16))
		end
	end
	warn(`[PlayerData] {label} gave up: {lastErr}`)
	return false, nil
end

local function replicate(player: Player)
	local profile = profiles[player]
	if not profile then
		return
	end
	local level = Progression.levelFromXP(profile.XP)
	player:SetAttribute("Coins", profile.Coins)
	player:SetAttribute("XP", profile.XP)
	player:SetAttribute("Level", level)
	player:SetAttribute("BestFloor", profile.Stats.BestFloor)
end

local function load(player: Player)
	local profile: Profile? = nil
	local canPersist = false

	if store then
		local ds = store :: DataStore
		for attempt = 1, Config.Data.LoadAttempts do
			local lockedByOther = false
			local ok, record = withRetry("load", 3, function()
				return ds:UpdateAsync(storeKey(player), function(old: any)
					old = if typeof(old) == "table" then old else {}
					local lock = old.Lock
					local isLast = attempt == Config.Data.LoadAttempts
					if
						not isLast
						and typeof(lock) == "table"
						and lock.JobId ~= game.JobId
						and os.time() - (tonumber(lock.Time) or 0) < Config.Data.SessionLockTimeout
					then
						lockedByOther = true
						return nil -- cancela: outra sessão ainda está ativa
					end
					old.Lock = { JobId = game.JobId, Time = os.time() }
					return old
				end)
			end)
			if not ok then
				break
			end
			if lockedByOther then
				task.wait(5)
				continue
			end
			profile = migrate((record :: any) and (record :: any).Profile)
			canPersist = true
			break
		end
	end

	if player.Parent ~= Players then
		return -- saiu durante o carregamento
	end

	if not profile then
		profile = defaultProfile()
		warn(`[PlayerData] {player.Name}: usando perfil em memória (não será salvo)`)
	end

	profiles[player] = profile :: Profile
	persist[player] = canPersist
	replicate(player)
	PlayerDataService.ProfileLoaded:Fire(player, profile)
end

local function save(player: Player, release: boolean)
	local profile = profiles[player]
	if not profile or not persist[player] or not store then
		return
	end
	local ds = store :: DataStore
	withRetry("save", 3, function()
		return ds:UpdateAsync(storeKey(player), function(old: any)
			old = if typeof(old) == "table" then old else {}
			local lock = old.Lock
			if typeof(lock) == "table" and lock.JobId ~= game.JobId then
				-- Outra sessão assumiu: não sobrescrever os dados dela.
				return nil
			end
			old.Profile = profile
			old.Lock = if release then nil else { JobId = game.JobId, Time = os.time() }
			return old
		end)
	end)
end

-- API pública ------------------------------------------------------------

function PlayerDataService.getProfile(player: Player): Profile?
	return profiles[player]
end

function PlayerDataService.addCoins(player: Player, amount: number)
	local profile = profiles[player]
	if not profile or amount <= 0 then
		return
	end
	profile.Coins += math.floor(amount)
	replicate(player)
end

function PlayerDataService.addXP(player: Player, amount: number)
	local profile = profiles[player]
	if not profile or amount <= 0 then
		return
	end
	profile.XP += math.floor(amount)
	replicate(player)
end

function PlayerDataService.updateStats(player: Player, mutate: (Stats) -> ())
	local profile = profiles[player]
	if not profile then
		return
	end
	mutate(profile.Stats)
	replicate(player)
end

-- Ciclo de vida ----------------------------------------------------------

function PlayerDataService.init()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Config.Data.StoreName)
	end)
	if ok then
		store = result
	else
		warn("[PlayerData] DataStore indisponível (Studio sem API Services?):", result)
	end
end

function PlayerDataService.start()
	Players.PlayerAdded:Connect(load)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		save(player, true)
		profiles[player] = nil
		persist[player] = nil
	end)

	game:BindToClose(function()
		if RunService:IsStudio() and not store then
			return
		end
		local pending = 0
		for player in profiles do
			pending += 1
			task.spawn(function()
				save(player, true)
				pending -= 1
			end)
		end
		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do
			task.wait(0.1)
		end
	end)

	while true do
		task.wait(Config.Data.AutosaveInterval)
		for player in profiles do
			task.spawn(save, player, false)
		end
	end
end

return PlayerDataService

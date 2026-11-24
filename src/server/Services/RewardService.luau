--!strict
-- Cálculo e entrega de recompensas — sempre no servidor.
-- Regra do ELEVATOR STREAK:
--   * XP do andar é garantido na hora.
--   * Coins do andar (x multiplicador do streak) ficam PENDENTES no run.
--   * Extrair no checkpoint (ou sobreviver até o fim) credita as pendentes.
--   * Ser eliminado perde só as pendentes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Progression = require(Shared.Util.Progression)
local GameTypes = require(Shared.GameTypes)
local PlayerDataService = require(script.Parent.PlayerDataService)

export type Run = {
	Alive: boolean,
	Extracted: boolean,
	Streak: number,
	PendingCoins: number,
	CoinsEarned: number,
	FloorsCleared: number,
	Choice: string?,
}

local RewardService = {}

function RewardService.newRun(): Run
	return {
		Alive = true,
		Extracted = false,
		Streak = 0,
		PendingCoins = 0,
		CoinsEarned = 0,
		FloorsCleared = 0,
		Choice = nil,
	}
end

function RewardService.multiplier(run: Run): number
	return Progression.multiplierForStreak(run.Streak)
end

-- Chamado para cada sobrevivente ao fim de um andar.
function RewardService.awardFloor(player: Player, def: GameTypes.FloorDefinition, run: Run)
	run.Streak += 1
	run.FloorsCleared += 1
	local mult = Progression.multiplierForStreak(run.Streak)
	run.PendingCoins += math.floor(def.Rewards.Coins * mult)
	PlayerDataService.addXP(player, def.Rewards.XP)
	PlayerDataService.updateStats(player, function(stats)
		stats.FloorsCleared += 1
	end)
end

-- Credita as coins pendentes. Retorna quanto foi creditado.
function RewardService.bank(player: Player, run: Run, isExtraction: boolean): number
	local amount = run.PendingCoins
	run.PendingCoins = 0
	run.CoinsEarned += amount
	PlayerDataService.addCoins(player, amount)
	if isExtraction then
		PlayerDataService.addXP(player, Config.Rewards.ExtractionBonusXP)
		PlayerDataService.updateStats(player, function(stats)
			stats.Extractions += 1
		end)
	end
	return amount
end

function RewardService.forfeit(run: Run)
	run.PendingCoins = 0
end

return RewardService

--!strict
-- Curva de nível. Pura: roda nos dois lados; o servidor é a autoridade.

local Config = require(script.Parent.Parent.Config)

local Progression = {}

function Progression.xpForLevel(level: number): number
	-- XP necessário para sair de `level` e ir para `level + 1`
	return math.floor(Config.Progression.BaseXP * Config.Progression.Growth ^ (level - 1))
end

-- Retorna nível, XP dentro do nível e XP necessário para o próximo.
function Progression.levelFromXP(totalXP: number): (number, number, number)
	local level = 1
	local remaining = math.max(0, math.floor(totalXP))
	while level < Config.Progression.MaxLevel do
		local need = Progression.xpForLevel(level)
		if remaining < need then
			return level, remaining, need
		end
		remaining -= need
		level += 1
	end
	return level, 0, 0
end

function Progression.multiplierForStreak(streak: number): number
	local m = 1 + math.max(0, streak) * Config.Rewards.StreakStep
	return math.min(m, Config.Rewards.MaxMultiplier)
end

return Progression

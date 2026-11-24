--!strict
-- Catálogo de andares. Para criar um andar novo:
--   1. Adicione a entrada aqui.
--   2. Crie o ModuleScript com o mesmo nome de `Module` em Server/Floors.
--   3. Mude Enabled para true só depois de testar.

local GameTypes = require(script.Parent.GameTypes)
type FloorDefinition = GameTypes.FloorDefinition

local Floors: { FloorDefinition } = {
	{
		Id = "dont_move",
		Number = 1,
		Name = "DON'T MOVE",
		Environment = "Hallway",
		Rule = "DON'T MOVE.",
		Objective = "Stay completely still until the timer ends.",
		Duration = 30,
		Difficulty = 1,
		MinimumPlayers = 1,
		Rewards = { Coins = 15, XP = 10 },
		Module = "DontMove",
		Enabled = true,
	},
	{
		Id = "wrong_color",
		Number = 2,
		Name = "WRONG COLOR",
		Environment = "Office",
		Rule = "WRONG COLOR.",
		Objective = "Stand on the announced color before the floor drops.",
		Duration = 40,
		Difficulty = 1,
		MinimumPlayers = 1,
		Rewards = { Coins = 20, XP = 10 },
		Module = "WrongColor",
		Enabled = true,
	},
	{
		Id = "floor_is_lava",
		Number = 3,
		Name = "THE FLOOR IS LAVA",
		Environment = "Warehouse",
		Rule = "THE FLOOR IS LAVA.",
		Objective = "Climb. Stay above the rising heat.",
		Duration = 45,
		Difficulty = 2,
		MinimumPlayers = 1,
		Rewards = { Coins = 25, XP = 15 },
		Module = "FloorIsLava",
		Enabled = true,
	},

	-- Planejados (GDD seção 5) — ainda sem módulo.
	{
		Id = "run",
		Number = 4,
		Name = "RUN",
		Environment = "Hallway",
		Rule = "RUN.",
		Objective = "Find the exit before it finds you.",
		Duration = 50,
		Difficulty = 2,
		MinimumPlayers = 1,
		Rewards = { Coins = 30, XP = 15 },
		Module = "Run",
		Enabled = false,
	},
	{
		Id = "lights_out",
		Number = 5,
		Name = "LIGHTS OUT",
		Environment = "Storage",
		Rule = "LIGHTS OUT.",
		Objective = "Find the exit in the dark.",
		Duration = 50,
		Difficulty = 2,
		MinimumPlayers = 1,
		Rewards = { Coins = 30, XP = 15 },
		Module = "LightsOut",
		Enabled = false,
	},
	{
		Id = "impostor",
		Number = 6,
		Name = "THE IMPOSTOR",
		Environment = "Office",
		Rule = "ONE OF YOU IS NOT A PASSENGER.",
		Objective = "Complete the task. Trust no one.",
		Duration = 60,
		Difficulty = 3,
		MinimumPlayers = 3,
		Rewards = { Coins = 35, XP = 20 },
		Module = "Impostor",
		Enabled = false,
	},
	{
		Id = "press_it",
		Number = 7,
		Name = "PRESS IT",
		Environment = "Storage",
		Rule = "PRESS IT?",
		Objective = "Decide. Or don't.",
		Duration = 35,
		Difficulty = 2,
		MinimumPlayers = 1,
		Rewards = { Coins = 25, XP = 15 },
		Module = "PressIt",
		Enabled = false,
	},
	{
		Id = "rising_water",
		Number = 8,
		Name = "RISING WATER",
		Environment = "Pool",
		Rule = "RISING WATER.",
		Objective = "Find high ground.",
		Duration = 45,
		Difficulty = 2,
		MinimumPlayers = 1,
		Rewards = { Coins = 25, XP = 15 },
		Module = "RisingWater",
		Enabled = false,
	},
}

local FloorRegistry = {}

function FloorRegistry.all(): { FloorDefinition }
	return Floors
end

function FloorRegistry.get(id: string): FloorDefinition?
	for _, def in Floors do
		if def.Id == id then
			return def
		end
	end
	return nil
end

return FloorRegistry

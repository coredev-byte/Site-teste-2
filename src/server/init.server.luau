--!strict
-- ELEVATOR — Bootstrap do servidor (único Script do servidor).
-- Duas fases: init() de todos os serviços; depois start() de todos.

local Services = script:WaitForChild("Services")

-- Ordem explícita: Net primeiro (cria os remotes), MatchService por último.
local ORDER = {
	"Net",
	"PlayerDataService",
	"RewardService",
	"ElevatorService",
	"FloorService",
	"MatchService",
}

local loaded: { { name: string, module: any } } = {}

for _, name in ORDER do
	local moduleScript = Services:FindFirstChild(name)
	if moduleScript and moduleScript:IsA("ModuleScript") then
		local ok, result = pcall(require, moduleScript)
		if ok then
			table.insert(loaded, { name = name, module = result })
		else
			warn(`[Bootstrap] failed to require {name}: {result}`)
		end
	else
		warn(`[Bootstrap] service not found: {name}`)
	end
end

for _, entry in loaded do
	if typeof(entry.module.init) == "function" then
		local ok, err = pcall(entry.module.init)
		if not ok then
			warn(`[Bootstrap] {entry.name}.init failed: {err}`)
		end
	end
end

for _, entry in loaded do
	if typeof(entry.module.start) == "function" then
		task.spawn(entry.module.start)
	end
end

print(`[ELEVATOR] server ready ({#loaded} services) — SYSTEM ACTIVE`)

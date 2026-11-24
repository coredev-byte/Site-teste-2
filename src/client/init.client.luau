--!strict
-- ELEVATOR — Bootstrap do cliente (único LocalScript).
-- Controllers só APRESENTAM estado; a lógica de jogo vive no servidor.

local Controllers = script:WaitForChild("Controllers")

local ORDER = {
	"StateController",
	"InterfaceController",
	"SpectatorController",
	"EffectsController",
}

local loaded: { { name: string, module: any } } = {}

for _, name in ORDER do
	local moduleScript = Controllers:FindFirstChild(name)
	if moduleScript and moduleScript:IsA("ModuleScript") then
		local ok, result = pcall(require, moduleScript)
		if ok then
			table.insert(loaded, { name = name, module = result })
		else
			warn(`[Client] failed to require {name}: {result}`)
		end
	end
end

for _, entry in loaded do
	if typeof(entry.module.init) == "function" then
		local ok, err = pcall(entry.module.init)
		if not ok then
			warn(`[Client] {entry.name}.init failed: {err}`)
		end
	end
end

for _, entry in loaded do
	if typeof(entry.module.start) == "function" then
		task.spawn(entry.module.start)
	end
end

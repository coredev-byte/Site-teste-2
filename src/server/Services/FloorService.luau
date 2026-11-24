--!strict
-- Escolhe, monta, executa e limpa andares. Cada andar é um módulo plugável em Server/Floors:
--
--   local Floor = {}
--   Floor.Arena = { Size = Vector3?, HasFloor = boolean? }   -- opcional (placeholder)
--   function Floor.setup(ctx) end    -- opcional: geometria extra antes de spawnar
--   function Floor.start(ctx) end    -- obrigatório: gameplay; registre tudo em ctx.Maid
--   function Floor.stop(ctx) end     -- opcional: chamado antes da limpeza
--   return Floor
--
-- O FloorService cuida do genérico: spawn, intro congelada, timer, queda no vazio,
-- morte do Humanoid, saída do jogador e limpeza total (Maid + Arena).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local FloorRegistry = require(Shared.FloorRegistry)
local GameTypes = require(Shared.GameTypes)
local Maid = require(Shared.Util.Maid)
local Net = require(script.Parent.Net)
local Builders = require(script.Parent.Parent.World.Builders)
local Characters = require(script.Parent.Parent.World.Characters)

type FloorDefinition = GameTypes.FloorDefinition

export type Context = {
	Definition: FloorDefinition,
	Arena: Model,
	Origin: Vector3,
	Maid: Maid.Maid,
	Random: Random,
	EndsAt: number,
	getAlive: () -> { Player },
	eliminate: (player: Player, reason: string) -> (),
	setObjective: (text: string, swatch: Color3?) -> (),
	fire: (payload: { [string]: any }) -> (), -- FloorEvent para todos
	timeLeft: () -> number,
	finish: () -> (), -- encerra o andar antes do tempo
}

export type Hooks = {
	getAlive: () -> { Player },
	eliminate: (player: Player, reason: string) -> (),
	onIntro: (def: FloorDefinition, endsAt: number) -> (),
	onStart: (def: FloorDefinition, endsAt: number) -> (),
	onObjective: (text: string, swatch: Color3?) -> (),
}

local FloorService = {}

local modules: { [string]: any } = {}
local recent: { string } = {}
local rng = Random.new()
local activeFolder: Folder

local function now(): number
	return Workspace:GetServerTimeNow()
end

function FloorService.init()
	local folder = script.Parent.Parent:FindFirstChild("Floors")
	for _, def in FloorRegistry.all() do
		if def.Enabled then
			local moduleScript = folder and folder:FindFirstChild(def.Module)
			if moduleScript and moduleScript:IsA("ModuleScript") then
				local ok, result = pcall(require, moduleScript)
				if ok and typeof(result) == "table" and typeof(result.start) == "function" then
					modules[def.Id] = result
				else
					warn(`[FloorService] módulo inválido para {def.Id}: {result}`)
				end
			else
				warn(`[FloorService] {def.Id} habilitado mas módulo {def.Module} não existe`)
			end
		end
	end

	local existing = Workspace:FindFirstChild("ActiveFloor")
	if existing and existing:IsA("Folder") then
		activeFolder = existing
	else
		activeFolder = Instance.new("Folder")
		activeFolder.Name = "ActiveFloor"
		activeFolder.Parent = Workspace
	end
end

-- Sorteia um andar jogável para N jogadores, evitando os últimos.
function FloorService.choose(playerCount: number): FloorDefinition?
	local candidates: { FloorDefinition } = {}
	local fallback: { FloorDefinition } = {}
	for _, def in FloorRegistry.all() do
		if modules[def.Id] and def.MinimumPlayers <= playerCount then
			table.insert(fallback, def)
			if not table.find(recent, def.Id) then
				table.insert(candidates, def)
			end
		end
	end
	local pool = if #candidates > 0 then candidates else fallback
	if #pool == 0 then
		return nil
	end
	local def = pool[rng:NextInteger(1, #pool)]
	table.insert(recent, def.Id)
	while #recent > Config.Match.RecentFloorMemory do
		table.remove(recent, 1)
	end
	return def
end

local function buildArena(def: FloorDefinition, floorModule: any): Model
	local origin = Config.World.FloorOrigin
	local templates = ServerStorage:FindFirstChild("FloorTemplates")
	local template = templates and templates:FindFirstChild(def.Environment)
	local arena: Model
	if template and template:IsA("Model") and template:FindFirstChild("SpawnArea", true) then
		arena = template:Clone()
		arena:PivotTo(CFrame.new(origin))
	else
		arena = Builders.arena(def.Environment, origin, floorModule.Arena)
	end
	arena.Parent = activeFolder
	return arena
end

-- Executa um andar inteiro. Yield até terminar. Sempre limpa, mesmo com erro.
function FloorService.run(def: FloorDefinition, hooks: Hooks)
	local floorModule = modules[def.Id]
	assert(floorModule, "floor module missing: " .. def.Id)

	local maid = Maid.new()
	local arena = buildArena(def, floorModule)
	maid:give(arena)
	local finished = false

	-- Declarado antes para que as closures abaixo enxerguem `ctx`.
	local ctx: Context
	ctx = {
		Definition = def,
		Arena = arena,
		Origin = Config.World.FloorOrigin,
		Maid = maid,
		Random = Random.new(),
		EndsAt = 0,
		getAlive = hooks.getAlive,
		eliminate = hooks.eliminate,
		setObjective = hooks.onObjective,
		fire = function(payload)
			payload.FloorId = def.Id
			Net.fireAll("FloorEvent", payload)
		end,
		timeLeft = function()
			return math.max(0, ctx.EndsAt - now())
		end,
		finish = function()
			finished = true
		end,
	}

	local ok, err = pcall(function()
		if typeof(floorModule.setup) == "function" then
			floorModule.setup(ctx)
		end

		-- Spawn + intro congelada
		local spawnArea = arena:FindFirstChild("SpawnArea", true)
		for _, player in hooks.getAlive() do
			if spawnArea and spawnArea:IsA("BasePart") then
				Characters.teleport(player, Builders.randomPointIn(spawnArea, ctx.Random))
			end
			Characters.setMovement(player, false)
		end
		hooks.onIntro(def, now() + Config.Match.FloorIntro)
		task.wait(Config.Match.FloorIntro)

		for _, player in hooks.getAlive() do
			Characters.setMovement(player, true)
		end
		ctx.EndsAt = now() + def.Duration
		hooks.onStart(def, ctx.EndsAt)

		-- Monitores genéricos: vazio e morte.
		local voidY = ctx.Origin.Y - Config.Match.VoidKillDepth
		maid:give(RunService.Heartbeat:Connect(function()
			for _, player in hooks.getAlive() do
				local root = Characters.root(player)
				if not root then
					hooks.eliminate(player, "Died")
				elseif root.Position.Y < voidY then
					hooks.eliminate(player, "Fell")
				end
			end
		end))

		floorModule.start(ctx)

		while not finished and now() < ctx.EndsAt and #hooks.getAlive() > 0 do
			task.wait(0.1)
		end
	end)
	if not ok then
		warn(`[FloorService] erro no andar {def.Id}: {err}`)
	end

	if typeof(floorModule.stop) == "function" then
		local stopOk, stopErr = pcall(floorModule.stop, ctx)
		if not stopOk then
			warn(`[FloorService] stop {def.Id}: {stopErr}`)
		end
	end
	maid:clean()
end

return FloorService

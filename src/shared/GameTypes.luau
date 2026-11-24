--!strict
-- Tipos que cruzam a fronteira cliente/servidor.

export type MatchState =
	"Lobby"
	| "Countdown"
	| "Elevator"
	| "FloorIntro"
	| "FloorActive"
	| "FloorResults"
	| "Checkpoint"
	| "Extraction"
	| "MatchEnded"

export type Environment = "Office" | "Hallway" | "Pool" | "Warehouse" | "Storage"

export type FloorRewards = {
	Coins: number,
	XP: number,
}

export type FloorDefinition = {
	Id: string,
	Number: number, -- número "de catálogo" (FLOOR 01, 02...)
	Name: string,
	Environment: Environment,
	Rule: string, -- texto curto e grande (ex.: "DON'T MOVE")
	Objective: string, -- instrução do HUD
	Duration: number,
	Difficulty: number,
	MinimumPlayers: number,
	Rewards: FloorRewards,
	Module: string, -- nome do ModuleScript em Server/Floors
	Enabled: boolean,
}

-- Snapshot público enviado a todos via GameState.
export type Snapshot = {
	State: MatchState,
	Floor: number, -- andar atual da partida (1, 2, 3...)
	EndsAt: number?, -- workspace:GetServerTimeNow() em que a fase termina
	FloorId: string?,
	FloorName: string?,
	Rule: string?,
	Objective: string?,
	ObjectiveSwatch: Color3?, -- andares podem destacar uma cor no objetivo
	Survivors: number,
	Participants: number,
	AliveUserIds: { number },
	Results: { ResultEntry }?,
}

export type ResultEntry = {
	UserId: number,
	Name: string,
	FloorsCleared: number,
	Outcome: "Extracted" | "Eliminated" | "Survived",
}

-- Estado pessoal enviado só ao dono via UIUpdate { Type = "Run" }.
export type PersonalRun = {
	Type: "Run",
	InRun: boolean,
	Alive: boolean,
	Extracted: boolean,
	Streak: number,
	Multiplier: number,
	PendingCoins: number,
	FloorsCleared: number,
	Choice: string?,
}

export type CheckpointChoice = "Continue" | "Extract"

-- ModuleScripts precisam retornar exatamente um valor.
return {}

--!strict
-- Tunables centralizados. Valores iniciais do GDD — ajustar após testes.
-- ATENÇÃO: este módulo é legível pelo cliente. Checagens autoritativas ficam no servidor.

local Config = {
	Match = {
		MaxPlayers = 10,
		MinPlayersToStart = 1,
		LobbyCountdown = 20, -- segundos
		ElevatorTransition = 10,
		FloorIntro = 3, -- jogadores congelados enquanto a regra é apresentada
		FloorResults = 5,
		CheckpointEvery = 3, -- checkpoint a cada N andares
		CheckpointDecisionTime = 10,
		-- Escolha aplicada a quem não responde (AFK). "Extract" protege o jogador.
		CheckpointDefaultChoice = "Extract",
		ExtractionDuration = 3,
		ResultsDuration = 8,
		EliminationReturnDelay = 2.5, -- tempo até voltar ao lobby após eliminação
		VoidKillDepth = 25, -- abaixo de (origem do andar - isto) = eliminado
		RecentFloorMemory = 2, -- não repetir os últimos N andares
	},

	Rewards = {
		-- Multiplicador do ELEVATOR STREAK: 1 + streak * Step, limitado a Max.
		StreakStep = 0.1,
		MaxMultiplier = 2,
		-- Coins do andar ficam "pendentes" (aplicado o multiplicador) até a extração.
		-- Morrer perde apenas as coins pendentes. XP é garantido na hora.
		ExtractionBonusXP = 15,
	},

	Progression = {
		BaseXP = 100, -- XP para o nível 2
		Growth = 1.25, -- cada nível exige 25% mais
		MaxLevel = 200,
	},

	Data = {
		StoreName = "ElevatorPlayerData_v1",
		AutosaveInterval = 120,
		SessionLockTimeout = 600, -- lock "velho" após 10 min pode ser assumido
		LoadAttempts = 5,
	},

	Net = {
		ActionsPerSecond = 8, -- limite por jogador no PlayerAction
	},

	World = {
		ElevatorOrigin = Vector3.new(0, 200, 0),
		FloorOrigin = Vector3.new(0, 60, 800),
		DefaultWalkSpeed = 16,
		DefaultJumpHeight = 7.2,
	},
}

return Config

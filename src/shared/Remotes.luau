--!strict
-- Lista única de remotes. O SERVIDOR cria (Server/Services/Net); o cliente só espera.
--   GameState   server -> all    Snapshot público da partida
--   FloorEvent  server -> all    Efeitos específicos de andar / elevador
--   UIUpdate    server -> one    Estado pessoal e avisos (eliminação, extração, resultados)
--   PlayerAction client -> server Intenções do jogador (validadas no servidor)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

Remotes.FolderName = "Remotes"
Remotes.Names = { "GameState", "FloorEvent", "UIUpdate", "PlayerAction" }

-- Ações aceitas no PlayerAction. Qualquer outra é descartada.
Remotes.Actions = {
	Ready = "Ready",
	CheckpointChoice = "CheckpointChoice",
}

function Remotes.waitFor(name: string): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild(Remotes.FolderName)
	local remote = folder:WaitForChild(name)
	assert(remote:IsA("RemoteEvent"), name .. " is not a RemoteEvent")
	return remote
end

return Remotes

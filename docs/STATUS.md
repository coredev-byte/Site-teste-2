# STATUS DO PROJETO

> **Nada aqui foi testado no Roblox Studio ainda.** O código foi escrito fora do Studio, sem
> analisador Luau disponível. A primeira tarefa no Claude Code é sincronizar, rodar e corrigir.

## Implementado (escrito, não testado)
| Etapa do prompt mestre | Arquivos |
| --- | --- |
| Foundation (config, tipos, registro, remotes, bootstrap) | `src/shared/*`, `src/server/init.server.luau`, `src/client/init.client.luau` |
| Elevator (portas, transição, display, embarque) | `src/server/Services/ElevatorService.luau` |
| MatchService (estados, eliminação, checkpoint, extração, resultados) | `src/server/Services/MatchService.luau` |
| FloorService (escolha, arena, intro, timer, queda, limpeza) | `src/server/Services/FloorService.luau` |
| Primeiros 3 andares | `src/server/Floors/DontMove.luau`, `WrongColor.luau`, `FloorIsLava.luau` |
| Recompensas + ELEVATOR STREAK | `src/server/Services/RewardService.luau` |
| Persistência (retry, lock de sessão, autosave, BindToClose) | `src/server/Services/PlayerDataService.luau` |
| UI: tokens, componentes, HUD contextual, intro, lobby, transição, checkpoint, resultados, espectador | `src/shared/UI/Theme.luau`, `src/client/UI/Components.luau`, `src/client/Controllers/*` |

## Placeholders (substituir por assets reais)
- **Lobby**: nenhum é gerado. Usa `Workspace.Lobby.Spawn` (BasePart) se existir; senão o SpawnLocation padrão.
- **Elevador**: gerado em `Config.World.ElevatorOrigin` se não existir `Workspace.Elevator` com:
  - `Inside` (BasePart invisível, área de embarque) — obrigatório
  - `DoorLeft`, `DoorRight` (BasePart) — opcionais, deslizam no eixo X local
  - um `TextLabel` chamado `Text` (ex.: `DisplayPanel.Display.Text`) — opcional
- **Ambientes**: gerados por `World/Builders.luau` se não houver `ServerStorage.FloorTemplates.<Office|Hallway|Pool|Warehouse|Storage>` (Model com uma BasePart `SpawnArea`).

## Criar manualmente no Studio
1. Game Settings → Security → **Enable Studio Access to API Services** (para testar DataStore).
2. Um `SpawnLocation` (ou `Workspace.Lobby.Spawn`) para o lobby.
3. `Players.CharacterAutoLoads = true` (padrão).

## Checklist de teste (MVP — GDD seção 16)
- [ ] Sem erros no Output ao iniciar (servidor e cliente)
- [ ] Lobby → countdown → elevador → andar → resultados → próximo andar
- [ ] Portas e transição
- [ ] DON'T MOVE, WRONG COLOR e THE FLOOR IS LAVA jogáveis
- [ ] Teste com 2+ clientes (Test → Clients and Servers)
- [ ] Eliminação, espectador e volta ao lobby
- [ ] Checkpoint no andar 3: Extrair e Continuar (mouse, teclado 1/2, controle X/Y, toque)
- [ ] Jogador saindo no meio não trava a partida
- [ ] Dados persistem entre sessões (Coins, XP, BestFloor)
- [ ] HUD em 1920×1080, 1280×720, iPhone (landscape) e tablet (Device Emulator)
- [ ] Limpeza: `Workspace.ActiveFloor` vazio entre andares, sem conexões vazando

## Riscos conhecidos
- DON'T MOVE lê a posição no servidor: a tolerância (1.6 studs) pode precisar de ajuste com latência real.
- WRONG COLOR: há vãos de 2 studs entre plataformas; alguém pode cair no spawn. Ajustar spawn/gaps.
- Fontes oficiais (Space Grotesk/Inter) não verificadas no Roblox — usando fallbacks nativos.
- Sem sons ainda (precisa de assets).
- Lock de sessão é simples (sem `MessagingService`); suficiente para o MVP.

## Próximas etapas (ordem do prompt mestre)
1. Sincronizar e **testar** tudo acima; corrigir erros.
2. Construir lobby e elevador reais (Blender/Studio) com as peças nomeadas acima.
3. Ambientes-base (Office, Hallway, Pool, Warehouse, Storage) em `ServerStorage.FloorTemplates`.
4. Andares 4–8, eventos raros.
5. Progressão completa (relíquias, quests), Hideout.
6. Monetização (MarketplaceService, ProcessReceipt no servidor, só cosméticos).
7. Polimento, sons, telas 10–14 de UI, publicação.

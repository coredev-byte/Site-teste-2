# ELEVATOR — instruções para o Claude Code

> **NO FLOOR IS THE SAME.** Jogo multiplayer de sobrevivência + minigames + exploração liminal no Roblox.
> Desenvolvimento solo com Claude + Roblox Studio. Nome final ainda em aberto (ELEVATOR vs THE ELEVATOR).

## Leia antes de qualquer trabalho
1. `docs/GDD.md` — documentação completa do jogo **e o PROMPT MESTRE (seção 17)**. É a fonte da verdade.
2. `docs/UI_PROMPT.md` — prompt do UI/UX Design System (HUD, lobby, painel, checkpoint…).
3. `docs/TOOLS_AND_REFERENCES.md` — plugins, iluminação liminal e referências.
4. `docs/STATUS.md` — o que já está implementado, o que **não foi testado** e as próximas etapas.

## Regras obrigatórias (resumo do prompt mestre)
- Nunca construir o jogo inteiro de uma vez. Etapas pequenas, validadas pelo usuário.
- Inspecionar o projeto (via MCP do Studio) antes de mudar qualquer coisa.
- Não sobrescrever sistemas/assets funcionais nem remover funcionalidades sem autorização.
- Não inventar APIs do Roblox. Luau correto, módulos pequenos.
- Servidor autoritativo: o cliente só envia intenções (`PlayerAction`), nunca valores.
- Nunca dizer que algo foi testado se não foi. Testar após cada etapa (2+ clientes quando for multiplayer).
- Ao fim de cada etapa: o que foi feito, arquivos criados/modificados, testes, problemas, próxima etapa.
- Informar o que precisa ser criado manualmente no Studio.

## Direção criativa
Liminal, nostálgico, misterioso, com humor — **não** terror genérico. UI minimalista, institucional, retrô-industrial.
Paleta: Charcoal `#252725`, Old Ivory `#D6CBB5`, Dusty Sage `#A3A18A`, Warning Amber `#C77B55`, Fog White `#E7E2D7`, Emergency Red `#A83C38`.
Todos os tokens ficam em `src/shared/UI/Theme.luau` — nunca hardcodar cor/fonte em outro lugar.

## Estrutura (Rojo — `default.project.json`)
```
src/shared  → ReplicatedStorage.Shared      (Config, GameTypes, FloorRegistry, Remotes, Util/, UI/Theme)
src/server  → ServerScriptService.Server     (init.server = Bootstrap; Services/; Floors/; World/)
src/client  → StarterPlayerScripts.Client    (init.client; Controllers/; UI/)
```
- Um único Script (`src/server/init.server.luau`) e um único LocalScript (`src/client/init.client.luau`). Todo o resto é ModuleScript.
- Bootstrap em duas fases: `init()` de todos os módulos, depois `start()`.
- Remotes criados **pelo servidor** em `ReplicatedStorage.Remotes`: `GameState`, `FloorEvent`, `UIUpdate`, `PlayerAction`.
- Cada andar = um módulo em `src/server/Floors/` + uma entrada em `src/shared/FloorRegistry.luau`.
- Ambientes: se existir `ServerStorage.FloorTemplates.<Environment>` (Office, Hallway, Pool, Warehouse, Storage), ele é usado; senão um placeholder é gerado por `src/server/World/Builders.luau`.
- Lobby: se existir `Workspace.Lobby.Spawn` (BasePart) é usado; senão o SpawnLocation padrão. Elevador: `Workspace.Elevator` (ver STATUS.md para as peças esperadas); senão placeholder.

## Comandos
- `rojo serve` + plugin Rojo no Studio para sincronizar.
- Ou, via MCP do Studio, criar as instâncias a partir dos arquivos de `src/` seguindo o mapeamento acima.

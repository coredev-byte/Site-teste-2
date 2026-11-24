# ELEVATOR — Especificação de UI/UX (v0.1)

Base: `docs/UI_PROMPT.md`. Implementação: `src/shared/UI/Theme.luau`, `src/client/UI/Components.luau`,
`src/client/Controllers/InterfaceController.luau`, `SpectatorController.luau`.

## 1. Princípios
- **Pertence ao mundo**: placas institucionais, displays de elevador, etiquetas técnicas. Não "menu de simulator".
- **Contextual**: cada estado da partida mostra só os blocos relevantes (tabela na seção 4).
- **Mobile-first**: referência 1280×720 com `UIScale` (mín. 0.72 → texto ≥ 9–10 px reais em celular; botões ≥ 40 px reais), safe area via `ScreenInsets.CoreUISafeInsets`.
- **Sem**: gradientes, neon na UI, cantos muito arredondados (raio 2 px), ícones cartunescos, animação gratuita.

## 2. Tokens
| Token | Valor |
| --- | --- |
| Surface | Charcoal `#252725` @ 12% transparência |
| Text / TextMuted | Fog White `#E7E2D7` / Dusty Sage `#A3A18A` |
| Accent (displays, números) | Warning Amber `#C77B55` |
| Danger (eliminação, tempo < 5 s) | Emergency Red `#A83C38` |
| Paper (placas no mundo) | Old Ivory `#D6CBB5` |
| Stroke | Dusty Sage, 1 px, 55% transparência |
| Fontes | Título: Montserrat Bold · Interface: Builder Sans · Números: Roboto Mono (substituir por Space Grotesk / Inter / mono oficial quando disponíveis) |
| Tamanhos | Eyebrow 13 · Body 18 · BodyLarge 22 · Title 30 · Display 44 · Hero 72 |
| Espaço | 4 · 8 · 12 · 20 · 32 |
| Movimento | Fast 0.12 s · Base 0.22 s · Slow 0.45 s (Quad/Quart Out) |

## 3. Wireframes

### Gameplay HUD (FloorActive)
```
┌──────────────────────────────────────────────────────────────────┐
│ FLOOR            ┌─[■] WRONG COLOR ───────── 00:27─┐ SURVIVORS 07/10│
│ 02               │ Stand on AMBER                  │ STREAK   x1.3  │
│ WRONG COLOR      │ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬───────── │ RUN      +46   │
│                  └─────────────────────────────────┘                │
│                                                                    │
│                         [ toast: ELIMINATED / YOU MOVED. ]          │
│                                                                    │
└──────────────────────────────────────────────────────────────────┘
```
- `[■]` = swatch opcional enviado pelo andar (`ObjectiveSwatch`).
- Timer fica vermelho nos últimos 5 s.

### Lobby (Lobby / Countdown)
```
┌──────────────────────────────────────────────────────────────────┐
│ PASSENGER LEVEL                                                    │
│ 04                                                                 │
│ 1.250 COINS                                                        │
│                                                                    │
│                        ┌─────────────────────┐                     │
│                        │    NEXT ELEVATOR    │                     │
│                        │        00:14        │                     │
│                        │ 3 PASSENGER(S) ...  │                     │
│                        │ NO FLOOR IS THE SAME│                     │
│                        └─────────────────────┘                     │
└──────────────────────────────────────────────────────────────────┘
```

### Elevador (Elevator)
Bloco inferior "DESTINATION UNKNOWN" com display rolando números aleatórios e travando no andar nos 2 s finais. Câmera treme levemente; luz oscila uma vez. O painel físico dentro da cabine (`DisplayPanel`, SurfaceGui) espelha o mesmo comportamento.

### Intro do andar (FloorIntro, jogadores congelados 3 s)
```
                         FLOOR 03
                   THE FLOOR IS LAVA.
                        ────────
             Climb. Stay above the rising heat.
```

### Checkpoint
```
            ┌───────────────────────────────────────────┐
            │                CHECKPOINT                 │
            │             FLOOR 03 CLEARED              │
            │  Extract now and keep your rewards — or   │
            │  ride on for a bigger multiplier.         │
            │  AT STAKE    +120                         │
            │  MULTIPLIER  x1.3                         │
            │  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬────────────────────  │
            │  [ EXTRACT  1 ]   [ CONTINUE  2 ]         │
            │      RIDING ON — WAITING FOR OTHERS       │
            └───────────────────────────────────────────┘
```

### Espectador
Barra inferior: `[<]  SPECTATING / NOME  [>]` — Q/E, L1/R1 ou toque.

### Resultados (MatchEnded)
"RIDE LOG" + "REACHED FLOOR 05" + até 6 linhas `01  Nome  FLOOR 05  EXTRACTED`.

## 4. Visibilidade por estado
| Estado | Profile | Lobby | Floor | Run | Transição | Intro | Objetivo | Checkpoint | Resultados | Espectador |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Lobby / Countdown | ● | ● | | | | | | | | |
| Elevator | | | ● | ● | ● | | | | | se fora do run |
| FloorIntro | | | ● | ● | | ● | | | | se fora do run |
| FloorActive | | | ● | ● | | | ● | | | se fora do run |
| FloorResults | | | ● | ● | toast | | | | | se fora do run |
| Checkpoint | | | ● | ● | | | | ● (vivos) | | se fora do run |
| Extraction | | | ● | ● | toast | | | | | se fora do run |
| MatchEnded | | | | | | | | | ● | |

## 5. Estados de componente
- **Botão**: normal · hover (−10% transparência) · pressed (escala 0.96) · disabled (60% + texto 50%) · selected/gamepad (contorno Fog White 2 px). Dica de input automática: `1/2` teclado, `X/Y` controle, nada no toque.
- **Painel**: padrão · alerta (traço Emergency Red — usado no toast de eliminação).
- **Timer**: âmbar · crítico ≤ 5 s vermelho.
- **Grupos**: entram com fade 0.22 s, saem com fade 0.12 s (CanvasGroup).

## 6. Entrada
| Ação | Teclado | Controle | Toque |
| --- | --- | --- | --- |
| Extrair | 1 | X | botão |
| Continuar | 2 | Y | botão |
| Espectar anterior/próximo | Q / E | L1 / R1 | botões < > |

## 7. Pendências de UI (próximas etapas)
Telas 10–14 do prompt (Shop, Inventário/Relíquias, Hideout, Settings, Quests), painel físico do elevador no lobby (SurfaceGui), sons de interface, opção "reduzir movimento" nas Settings, revisão em dispositivos reais.

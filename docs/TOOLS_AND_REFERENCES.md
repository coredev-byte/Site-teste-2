# Ferramentas, plugins e referências

## Conexão com o Studio
- **MCP nativo do Roblox Studio**: Assistant → … → Manage MCP Servers → "Enable Studio as MCP server". Permite ao Claude Code ler o DataModel, criar/rodar scripts, editar instâncias e fazer playtest.
- **Rojo** (ou Azul): sincroniza a pasta `src/` com o Studio. Este repositório já vem com `default.project.json`.

## Plugins recomendados
| Área | Plugin | Uso no ELEVATOR |
| --- | --- | --- |
| Código | Script Editor++ | StyLua dentro do Studio |
| UI | AutoScale Lite/Plus | Scale + UIAspectRatioConstraint para mobile |
| UI | Pixel Perfect, LayoutLint | Alinhamento e correção de layout |
| UI | Material Icons | Ícones minimalistas consistentes |
| UI 3D | SurfaceGui Editor | Painel do elevador, placas "FLOOR NOT FOUND" |
| Iluminação | Atmos (Elttob, pago) | Névoa/atmosfera por andar |
| Build | F3X Building Tools, Archimedes | Corredores e salas modulares |

## Iluminação liminal
- `Lighting.Technology = Future` (reflexos no metal do elevador).
- Preferir **SurfaceLight** em painéis de teto em vez de PointLight (luz fluorescente).
- Bloom e ColorCorrection discretos; nada de saturação alta.

## Referências
- Regretevator, Normal Elevator (concorrentes diretos — estudar e se diferenciar).
- Pressure, Doors (padrão de qualidade de transições, som e UI no Roblox).
- The Exit 8 (liminal + regras simples).
- Backrooms (Kane Parsons), Severance (UI corporativa retrô), Poolrooms.

## Fontes
Space Grotesk / Inter podem não existir nativamente no Roblox. Ver `src/shared/UI/Theme.luau`:
as fontes ficam centralizadas e podem ser trocadas em um único lugar
(fallbacks atuais: Montserrat para títulos, BuilderSans para interface, RobotoMono para números).

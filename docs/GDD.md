ELEVATOR — DOCUMENTAÇÃO COMPLETA DO PROJETO

Tagline: NO FLOOR IS THE SAME.

Plataforma: Roblox
Gênero: Multiplayer Survival + Party Minigames + Social Chaos + Liminal Exploration
Desenvolvimento: Solo, utilizando Claude AI e Roblox Studio.
Objetivo: Criar um jogo com alto potencial de viralização, retenção e monetização, mas que seja viável de desenvolver e manter por uma única pessoa.

⸻

1. CONCEITO DO JOGO

ELEVATOR é um jogo multiplayer de sobrevivência e desafios no Roblox, ambientado em um universo liminal misterioso.

Os jogadores entram em um elevador que os leva a andares imprevisíveis, cada um com desafios diferentes que misturam humor, tensão, terror e competição.

A cada andar, precisam sobreviver, conquistar recompensas e decidir se continuam arriscando ou garantem o que ganharam.

O elevador é o elemento central da experiência. Ele não é apenas um lobby: é a identidade do jogo, o responsável pelas transições, surpresas e pela sensação de que qualquer coisa pode acontecer.

A experiência deve ser divertida com amigos, mas também funcionar para quem joga sozinho.

Objetivo principal

Criar uma experiência que faça o jogador pensar:

* Só mais um andar.
* Quero descobrir o próximo.
* Dessa vez vou chegar mais longe.
* Preciso mostrar esse andar para meus amigos.
* Não acredito que isso acabou de acontecer.

O jogo deve gerar situações inesperadas e momentos naturalmente compartilháveis.

⸻

2. IDENTIDADE VISUAL

Direção artística

Estética liminal: lugares familiares que parecem estranhamente errados.

Não queremos um jogo de terror genérico, cheio de sangue, escuridão e monstros.

Queremos ambientes que transmitam desconforto, nostalgia, curiosidade e mistério.

Referências visuais:

* Hotéis antigos.
* Escritórios abandonados.
* Corredores infinitos.
* Elevadores metálicos.
* Piscinas vazias.
* Estacionamentos subterrâneos.
* Supermercados silenciosos.
* Salas de manutenção.
* Iluminação fluorescente.
* Carpetes geométricos.
* Paredes bege, cinza e verde desbotado.

Paleta oficial

* Charcoal: #252725
* Old Ivory: #D6CBB5
* Dusty Sage: #A3A18A
* Warning Amber: #C77B55
* Fog White: #E7E2D7
* Emergency Red: #A83C38

Tipografia

* Space Grotesk para títulos.
* Inter para interfaces.
* Fonte monoespaçada para painéis, números e indicadores.

Identidade da marca

Nome: ELEVATOR

Tagline: NO FLOOR IS THE SAME.

Outras frases ambientais:

* EST. 1999
* SYSTEM ACTIVE
* AN UNEXPECTED JOURNEY
* FLOOR NOT FOUND
* PLEASE WAIT
* DESTINATION UNKNOWN

A logo deve ser tipográfica, minimalista e memorável. Nada de mascotes genéricos, ícones aleatórios ou gradientes exagerados.

⸻

3. ESTRUTURA DO MUNDO

O mundo será dividido em três áreas principais.

THE LOBBY

O ambiente principal.

Deve conter:

* Elevador central.
* Painel de andares.
* Placar de jogadores.
* Loja.
* Inventário.
* Área de espera.
* Espaço para encontrar amigos.
* Pequenos segredos e elementos interativos.

O lobby precisa ser visualmente marcante, pois será a primeira impressão do jogador.

THE FLOORS

São os ambientes dos desafios.

Em vez de criar dezenas de mapas enormes, vamos desenvolver cinco ambientes-base reutilizáveis:

1. Office.
2. Hallway.
3. Pool.
4. Warehouse.
5. Storage.

Cada ambiente poderá receber diferentes obstáculos, iluminação, objetos e regras.

Isso permite criar muitos desafios sem precisar construir um mapa completamente novo para cada andar.

THE HIDEOUT

Um espaço pessoal do jogador.

Possíveis funcionalidades:

* Exibir relíquias.
* Mostrar troféus.
* Personalizar o ambiente.
* Exibir estatísticas.
* Mostrar companions cosméticos.
* Exibir conquistas.

⸻

4. GAMEPLAY PRINCIPAL

O ciclo básico:

1. Jogadores entram no lobby.
2. O elevador começa a contagem regressiva.
3. As portas se fecham.
4. O elevador apresenta uma transição.
5. As portas abrem em um andar inesperado.
6. Os jogadores recebem uma regra.
7. O desafio começa.
8. Os jogadores sobrevivem ou são eliminados.
9. Os sobreviventes recebem recompensas.
10. Em checkpoints, podem continuar ou sacar seus ganhos.
11. O ciclo continua até a derrota ou extração final.

Duração inicial sugerida

* Lobby: aproximadamente 20 segundos.
* Transição do elevador: aproximadamente 10 segundos.
* Desafio: 30–60 segundos.
* Recompensa: aproximadamente 5 segundos.
* Checkpoint: a cada três andares.

Uma partida deve durar aproximadamente 5–10 minutos, dependendo do desempenho dos jogadores.

Esses tempos devem ser ajustados após testes.

Multiplayer

* Até 10 jogadores por partida inicialmente.
* Não permitir entrada de novos jogadores no meio da rodada.
* Jogadores eliminados podem assistir aos sobreviventes.
* A saída de um jogador não pode quebrar a partida.
* O jogo deve funcionar com apenas um jogador.
* O sistema deve suportar partidas com poucos participantes.

⸻

5. OS PRIMEIROS OITO ANDARES

Cada andar deve ser um módulo independente.

FLOOR 01 — DON’T MOVE

Os jogadores entram em uma sala.

Uma mensagem aparece:

DON’T MOVE.

O jogador precisa permanecer imóvel durante o tempo determinado.

Qualquer movimento pode resultar em eliminação.

FLOOR 02 — WRONG COLOR

Uma cor é anunciada.

Os jogadores precisam correr para a plataforma correspondente.

Quem escolher a cor errada é eliminado.

FLOOR 03 — THE FLOOR IS LAVA

A lava começa a subir.

Os jogadores precisam encontrar plataformas seguras e sobreviver até o final.

FLOOR 04 — RUN

Uma criatura começa a perseguir os jogadores.

É necessário encontrar a saída antes que o tempo acabe.

FLOOR 05 — LIGHTS OUT

As luzes se apagam.

Os jogadores precisam encontrar a saída utilizando iluminação limitada e referências do ambiente.

FLOOR 06 — THE IMPOSTOR

Um jogador recebe uma missão secreta.

Ele precisa atrapalhar os demais sem ser descoberto.

O andar deve criar situações sociais e suspeitas.

FLOOR 07 — PRESS IT

Existe um botão no centro da sala.

Os jogadores precisam decidir se devem apertá-lo.

A consequência é desconhecida e pode mudar completamente o desafio.

FLOOR 08 — RISING WATER

A água começa a subir.

Os jogadores precisam encontrar locais elevados e sobreviver.

Requisitos de cada andar

Cada módulo precisa possuir:

* ID único.
* Nome.
* Ambiente.
* Regra principal.
* Objetivo.
* Timer.
* Condição de vitória.
* Condição de eliminação.
* Recompensas.
* Configuração de dificuldade.

Todos os andares devem ser independentes e plugáveis ao FloorService.

⸻

6. EVENTOS ALEATÓRIOS

O jogo precisa ter acontecimentos raros para gerar momentos inesperados.

Exemplos:

* Cabeças gigantes.
* Gravidade invertida.
* Luzes apagando.
* Andar inexistente.
* Um jogador recebendo uma missão secreta.
* Velocidade reduzida.
* Mudanças inesperadas no ambiente.
* Eventos especiais durante a partida.

Esses eventos devem ser raros, justos e compreensíveis.

Não devem parecer bugs ou prejudicar injustamente os jogadores.

⸻

7. SISTEMA DE PROGRESSÃO

O jogo terá quatro sistemas principais.

COINS

Moeda principal.

Obtida através de:

* Partidas.
* Desafios.
* Missões.
* Conquistas.

Utilizada principalmente para cosméticos.

XP

Experiência do jogador.

Obtida ao completar desafios e participar das partidas.

Utilizada para subir de nível.

RELICS

Colecionáveis encontrados durante as partidas.

Podem possuir:

* Raridade.
* Descrição.
* Aparência própria.
* Origem.
* Categoria.

A coleção deve incentivar exploração e repetição.

SEASONAL TOKENS

Moeda temporária para eventos e itens limitados.

⸻

8. SISTEMAS DE RETENÇÃO

O jogo precisa ter motivos para o jogador voltar.

Funcionalidades planejadas:

* Daily Quests.
* Weekly Quests.
* Achievements.
* Relics Collection.
* Player Levels.
* Personal Best Floor.
* Leaderboards.
* Rotating Events.
* Recompensas por jogar com amigos.
* Progressão sazonal.
* Personal Hideout.

ELEVATOR STREAK

Sistema de multiplicador de recompensas.

Quanto mais andares o jogador consegue completar consecutivamente, maior pode ser seu multiplicador.

Nos checkpoints, o jogador pode decidir:

* Sacar as recompensas.
* Continuar arriscando.

Se morrer, perde apenas os bônus ou recompensas ainda não extraídos, conforme as regras da partida.

Recompensas permanentes e itens já garantidos não devem desaparecer.

⸻

9. MONETIZAÇÃO

A monetização deve ser principalmente cosmética.

Não queremos pay-to-win.

Produtos sugeridos

Produto	Preço inicial sugerido
VIP	249 Robux
Skin Pack	99 Robux
Animações	49 Robux
Companion	149 Robux
Efeitos de entrada	79 Robux
Premium Pass	299 Robux

Os valores são hipóteses iniciais e precisam ser testados.

Possibilidades de monetização

* VIP.
* Skins.
* Animações.
* Companions cosméticos.
* Efeitos de entrada.
* Efeitos de vitória.
* Personalização do elevador.
* Personalização do Hideout.
* Premium Pass.
* Pacotes cosméticos sazonais.

Não vender:

* Imunidade à morte.
* Vitória garantida.
* Vantagens competitivas injustas.
* Itens que eliminem o desafio.

Compras precisam ser verificadas pelo servidor através do MarketplaceService.

Não implementar caixas pagas com probabilidades obscuras.

⸻

10. ARQUITETURA TÉCNICA

A estrutura deve ser modular, organizada e preparada para expansão.

Estrutura sugerida

ReplicatedStorage/

* Shared/
    * Config
    * FloorRegistry
    * GameTypes
    * Utilities
* Remotes/
    * GameState
    * FloorEvent
    * UIUpdate
    * PlayerAction

ServerScriptService/

* Bootstrap.server.lua
* Services/
    * MatchService
    * ElevatorService
    * FloorService
    * PlayerDataService
    * RewardService
    * QuestService
    * MonetizationService

ServerStorage/

* FloorTemplates/
* EnvironmentAssets/
* NPCs/

StarterPlayer/

* StarterPlayerScripts/
    * ClientController
    * CameraController
    * AudioController
    * EffectsController

StarterGui/

* MainHUD
* LobbyUI
* ShopUI
* CollectionUI
* ResultsUI

Workspace/

* Lobby
* Elevator
* ActiveFloor
* Hideout

Responsabilidades dos serviços

MatchService

Controla os estados da partida:

* Lobby.
* Countdown.
* Elevator.
* FloorActive.
* FloorResults.
* Checkpoint.
* Extraction.
* MatchEnded.

ElevatorService

Responsável por:

* Portas.
* Transições.
* Animações.
* Iluminação.
* Sons.
* Painel de andares.

FloorService

Responsável por:

* Escolher os desafios.
* Inicializar os andares.
* Controlar os timers.
* Verificar condições.
* Encerrar os desafios.
* Limpar os ambientes.

PlayerDataService

Responsável por:

* Salvar dados.
* Carregar dados.
* Gerenciar moedas.
* Gerenciar XP.
* Gerenciar relíquias.
* Gerenciar estatísticas.

RewardService

Responsável por calcular e entregar recompensas no servidor.

QuestService

Responsável pelas missões diárias, semanais e conquistas.

MonetizationService

Responsável por validar compras e conceder produtos.

Segurança

* O servidor deve ser autoritativo.
* RemoteEvents devem ser validados.
* Nunca confiar em valores enviados pelo cliente.
* DataStoreService deve ser implementado com segurança.
* Compras devem ser processadas no servidor.
* Jogadores desconectados não podem travar partidas.
* Limpar conexões, objetos e eventos ao terminar cada andar.
* Evitar replicação desnecessária.
* Evitar RemoteEvents excessivos.

⸻

11. EXEMPLO DE CONFIGURAÇÃO DE UM ANDAR

WRONG COLOR:

* Duration: 40 segundos.
* Environment: Office.
* Difficulty: 1.
* MinimumPlayers: 1.
* Rewards:
    * Coins: 20.
    * XP: 10.

A configuração deve ser facilmente modificável sem precisar alterar toda a lógica do jogo.

⸻

12. EXPERIÊNCIA E QUALIDADE

O jogo precisa funcionar em:

* PC.
* Mobile.
* Tablet.

As interfaces devem ser adaptáveis.

Requisitos:

* Instruções visuais e textuais.
* Controles intuitivos.
* Animações fluidas.
* Transições profissionais.
* Sons ambientais.
* Feedback claro de vitória e derrota.
* Performance adequada.
* Sistemas que funcionem em multiplayer.

Não exagerar em efeitos que prejudiquem o desempenho.

O jogo deve parecer profissional, mesmo com poucos recursos.

⸻

13. ESTRATÉGIA DE VIRALIZAÇÃO

A viralização deve surgir da própria experiência.

Precisamos criar situações que gerem vídeos naturalmente.

Exemplos:

* Um andar inesperado.
* Uma morte engraçada.
* Uma traição.
* Um jogador sobrevivendo por pouco.
* Um evento raro.
* Uma sequência de andares extremamente difícil.
* Uma decisão errada no checkpoint.

Conteúdo para vídeos

Vídeos curtos de 10–25 segundos.

Possíveis formatos:

* Reação ao abrir uma porta.
* Desafio inesperado.
* Jogador traindo os amigos.
* Evento secreto.
* Recorde de andares.
* Situação absurda durante uma partida.

O objetivo é criar conteúdo que as pessoas tenham vontade de compartilhar.

Métricas importantes

* Retenção D1.
* Retenção D7.
* Tempo médio de sessão.
* Partidas por jogador.
* Jogadores que voltam.
* Jogadores que jogam com amigos.
* Conclusão do tutorial.
* Compras.
* Replays.
* Avaliações positivas.

Metas iniciais de teste sugeridas:

* D1: 20% ou mais.
* Sessão média: 8 minutos ou mais.
* Tutorial concluído: 80% ou mais.
* Replay: 40% ou mais.
* Avaliações positivas: 85% ou mais.

Esses números são objetivos internos, não garantias de desempenho.

⸻

14. ROADMAP DE DESENVOLVIMENTO

FASE 1 — FOUNDATION

* Estrutura de pastas.
* Arquitetura.
* Configurações.
* Estados da partida.
* Serviços principais.

FASE 2 — LOBBY & ELEVATOR

* Construção do lobby.
* Elevador funcional.
* Portas.
* Painel.
* Iluminação.
* Transições.
* Sons.

FASE 3 — CORE GAMEPLAY

* Sistema de partidas.
* Entrada de jogadores.
* Contagem regressiva.
* Teleporte.
* Espectadores.
* Eliminação.
* Encerramento.

FASE 4 — FIRST FLOORS

Começar com três desafios:

1. DON’T MOVE.
2. WRONG COLOR.
3. THE FLOOR IS LAVA.

Depois adicionar os demais.

FASE 5 — PROGRESSION

* Coins.
* XP.
* Relics.
* DataStore.
* Estatísticas.
* Recordes.

FASE 6 — CONTENT EXPANSION

* Outros desafios.
* Eventos raros.
* Hideout.
* Mais ambientes.

FASE 7 — MONETIZATION

* Loja.
* VIP.
* Produtos.
* Cosméticos.
* Premium Pass.

FASE 8 — LAUNCH

* Thumbnail.
* Ícone.
* Descrição.
* Testes mobile.
* Testes multiplayer.
* Analytics.
* Publicação.

A estimativa inicial de desenvolvimento foi de aproximadamente 11–21 dias, mas isso depende da complexidade, dos testes e da velocidade de implementação. Não é uma garantia.

⸻

15. O QUE NÃO FAZER NO INÍCIO

Para manter o desenvolvimento viável para uma única pessoa, não começar com:

* 30 ou mais andares.
* Mundo aberto.
* Chat de voz próprio.
* Pets complexos.
* Trading.
* Guilds.
* Passe de temporada completo.
* Dezenas de monstros.
* Sistemas sociais complexos.

Primeiro precisamos provar que o ciclo principal é divertido.

⸻

16. CRITÉRIOS PARA CONSIDERAR O MVP PRONTO

* Scripts sem erros.
* Elevador funcionando.
* Portas e transições funcionando.
* Pelo menos três andares jogáveis.
* Teste com dois ou mais clientes.
* Vitória e derrota funcionando.
* Eliminação funcionando.
* Espectadores funcionando.
* Cleanup funcionando.
* Jogador desconectando sem quebrar a partida.
* Dados persistindo.
* Recompensas funcionando.
* Interface adaptada para mobile.
* Eventos sem prender jogadores.
* Compras verificadas pelo servidor.

Não afirmar que algo está pronto sem testar de verdade.

⸻

17. PROMPT MESTRE PARA CLAUDE

Você é um desenvolvedor sênior especializado em Roblox Studio, Luau, arquitetura multiplayer, game design, sistemas de progressão e experiências virais no Roblox.

Seu trabalho é desenvolver o projeto ELEVATOR, seguindo rigorosamente toda a documentação acima.

SUA MISSÃO

Transformar ELEVATOR em um jogo Roblox funcional, polido, otimizado e preparado para publicação.

O projeto será desenvolvido por uma única pessoa com sua assistência.

Portanto, priorize:

* Arquitetura simples e escalável.
* Código modular.
* Reutilização de sistemas.
* Facilidade de manutenção.
* Performance.
* Experiência mobile.
* Segurança multiplayer.
* Implementação incremental.

REGRAS OBRIGATÓRIAS

1. Nunca tente construir o jogo inteiro de uma vez.
2. Primeiro inspecione o projeto existente.
3. Nunca sobrescreva sistemas sem entender suas dependências.
4. Não remova funcionalidades existentes sem autorização.
5. Não invente APIs do Roblox.
6. Utilize Luau corretamente.
7. Evite scripts gigantes e monolíticos.
8. Mantenha a lógica importante no servidor.
9. Valide todas as ações dos jogadores.
10. Organize os módulos de maneira consistente.
11. Faça testes após cada etapa.
12. Informe exatamente o que foi criado e onde.
13. Informe quais objetos precisam ser criados manualmente no Roblox Studio.
14. Nunca diga que algo foi testado se não foi.
15. Se houver uma integração MCP disponível, utilize-a para inspecionar e manipular o Roblox Studio, respeitando os recursos efetivamente disponíveis.
16. Não substitua assets ou sistemas funcionais sem necessidade.
17. Não use soluções temporárias como se fossem definitivas.

DIREÇÃO CRIATIVA

Siga a identidade liminal estabelecida.

Não crie uma estética genérica de terror.

A experiência precisa transmitir personalidade, mistério, nostalgia e humor.

A interface deve ser profissional, minimalista e consistente.

O lobby e o elevador são os elementos visuais mais importantes.

ORDEM DE EXECUÇÃO

Primeiro:

* Inspecione o projeto.
* Identifique a estrutura existente.
* Verifique os recursos disponíveis.
* Identifique limitações.
* Apresente uma arquitetura recomendada.
* Liste os assets necessários.
* Liste os riscos técnicos.

Depois, desenvolva em etapas:

1. Foundation.
2. Lobby.
3. Elevator.
4. MatchService.
5. FloorService.
6. Primeiros três andares.
7. Recompensas.
8. Persistência.
9. Progressão.
10. Outros andares.
11. Monetização.
12. Polimento.
13. Testes.
14. Preparação para publicação.

Ao terminar cada etapa, apresente:

* O que foi implementado.
* Arquivos criados ou modificados.
* Sistemas funcionais.
* Testes realizados.
* Problemas encontrados.
* Próxima etapa recomendada.

PRIMEIRA AÇÃO

Não comece construindo o jogo inteiro.

Inspecione o projeto atual e apresente um diagnóstico técnico.

Depois proponha a primeira implementação concreta: a estrutura base do ELEVATOR, incluindo os serviços, estados da partida e organização dos módulos.

Aguarde a validação antes de avançar para uma etapa grande.

O objetivo não é apenas criar um jogo que funcione. É criar um jogo que as pessoas queiram jogar repetidamente, compartilhar com amigos e reconhecer pela sua identidade própria.

⸻

18. VISÃO FINAL

ELEVATOR deve ser uma experiência multiplayer de partidas rápidas, desafios imprevisíveis e progressão contínua.

O elevador conecta tudo.

Cada porta aberta representa uma nova possibilidade.

Alguns andares serão engraçados. Outros serão tensos. Alguns serão absurdos. Outros serão extremamente difíceis.

O jogador nunca deve saber exatamente o que encontrará.

ELEVATOR — NO FLOOR IS THE SAME.
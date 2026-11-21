# Jogo da Velha — Mobile

Partidas rápidas contra o computador e, futuramente, no mesmo aparelho.

## Diretrizes do projeto

- **Um único aplicativo na Google Play**: versão gratuita com anúncios e compra interna permanente **Pro — remover anúncios**. Não haverá aplicativo Pro separado.
- A compra Pro é **não consumível** e seu direito deve ser consultado/restaurado via **Google Play Billing** no início, após a compra e ao retornar ao app. Nunca exigir nova compra após uma atualização ou reinstalação na mesma conta habilitada.
- Enquanto a compra é carregada ou a Play Store está indisponível, lidar com o estado sem perder a titularidade. A restauração precisa de testes de compra, atualização, reinstalação e uso offline.
- Anúncios apenas em pausas naturais da experiência, **nunca durante a partida**; não há IDs de anúncios de produção neste repositório inicial.
- O menu principal terá **"Conheça nossos jogos"**: sugerir a instalação dos outros jogos publicados do catálogo, sem mostrar o próprio jogo. Cada entrada aponta para a página válida da Google Play; jogos ainda não publicados não devem gerar botões de instalação quebrados.
- A seção de outros jogos deve ser discreta, não bloquear o jogo e poder ser atualizada à medida que mais títulos forem publicados.
- **Tecnologia inicial**: Godot 4 / GDScript; Android 7 (API 24) ou superior e ARM64 como alvo mínimo, seguindo a base do Pong quando fizer sentido.
- O código-fonte será público. APKs/AABs de teste e assinaturas não devem ser publicados como artefatos públicos; usar o repositório privado `pitinga/game-mobile-builds` e distribuição controlada.
- Não armazenar segredos, chaves de assinatura nem IDs reais de produção no código.

## Estado

Repositório inicializado para desenvolvimento. Ainda não há jogo implementado nem integração real de compras, anúncios ou links da Play Store. Essas são regras aprovadas para a implementação e testes.

## Catálogo

Este jogo faz parte da coleção de minijogos de [pitinga](https://github.com/pitinga), incluindo [Pong Mobile](https://github.com/pitinga/game-pong-mobile). A indicação de instalação no aplicativo será ativada apenas para títulos efetivamente disponíveis na Google Play.

# Handoff — Emplake (Flutter Web)

Atualizado em 14/11/2026. Prazo da entrega: **16/11/2026**.

## Leia primeiro
1. `docs/plano-implementacao.md`: plano, stack obrigatória, checklist do professor (seção 10).
2. `docs/pendencias.md`: o que falta resolver fora do código.
3. `docs/engenharia-reversa-emplake.md`: regras do jogo original (só como referência; o enunciado do professor manda).

## Estado atual (tudo commitado em `main`, 4 commits ainda não enviados ao GitHub)
- **Domínio do jogo** (`lib/features/game/domain/`): tokens, 4 níveis exatamente como o enunciado, parser próprio, avaliador, juiz (`judge`) e LaTeX. 44 testes em `test/domain/judge_test.dart`, todos passando.
- **Tela de jogo** (`lib/features/game/ui/`, estado em `state/game_controller.dart` com Riverpod `NotifierProvider.family` por nível):
  - arrastar e soltar com espaço animado no ponto de inserção;
  - `=` como peça única fora da expressão;
  - prévia LaTeX ao vivo (`flutter_math_fork`);
  - Verificar, Limpar e Pular;
  - ao acertar, as peças voam de volta para a paleta (`flight_layer.dart`) e um número novo é sorteado;
  - a peça com erro fica com borda vermelha e treme.
- **Visual** (`lib/core/theme/`, `lib/core/ui/`): estilo indie retrô, com 3 temas prontos via `ThemeExtension` `GamePalette` (felt, cosmic, minimal).
  - Fonte pixel Jersey 10 em título, abas e botões; Inter no resto.
  - Fundo com curvas de nível geradas uma vez (`contour_pattern.dart`), granulado e vinheta.
  - Botão de paleta temporário no topo da tela alterna os temas.
- **i18n**: ARB PT/EN em `lib/l10n/`, gerado em `lib/l10n/gen/` (entrega é só `.dart`). Hoje segue o idioma do navegador.
- **Firebase**: projeto `emplake-ddm-6ab5b` (Spark).
  - `lib/firebase_options.dart` gerado (só web).
  - Regras do Firestore publicadas (`firestore.rules`: cada usuário só acessa `users/{uid}/**`).
  - Hosting configurado em `firebase.json` (`build/web`, rewrite para SPA).
  - **O app ainda não inicializa o Firebase** (`main.dart` não chama `Firebase.initializeApp`).

## Próximos passos (ordem sugerida)
1. **Login** com `firebase_ui_auth` (e-mail/senha + Google, que precisa do *Web client ID* que o Thales vai mandar), com:
   - nomes do grupo: **Caio Monteiro Arraes** e **Thales Leonardo Euler Vieira de Sousa**;
   - seletor de idioma com bandeiras (`country_flags`);
   - `firebase_ui_localizations` nos delegates.
2. **Rotas** com `go_router`: `/login` fora do shell; `StatefulShellRoute` com `curved_navigation_bar` (Jogar, Histórico, Ajuda via `showDialog`, Configurações); `redirect` pelo estado de auth.
3. **Configurações** (Riverpod + `shared_preferences`):
   - tema claro/escuro/sistema (falta criar a versão clara dos temas);
   - tamanho da fonte;
   - família da fonte (`google_fonts`);
   - cor semente ligada aos acentos;
   - temas prontos (os 3 que já existem);
   - idioma;
   - som (desligado por padrão).
4. **Firestore** com `FutureBuilder` e `loading_animation_widget`:
   - `users/{uid}/solved/{level}_{nnnn}`;
   - sortear só números não resolvidos **por nível**;
   - histórico;
   - pontuação.
5. Seletor de nível vira página própria; remover o botão temporário de tema.
6. Restaurar a última rota ao reabrir (`shared_preferences`), deploy no Firebase Hosting e revisar o checklist.

## Decisões já tomadas
- Usar `package:flutter/material.dart` (obsoleto no Flutter 3.50). O `material_ui` é uma cópia separada e quebra o tema e as traduções dentro de firebase_ui, flutter_math etc. O aviso está desligado em `analysis_options.yaml`.
- `google_fonts` 9 usa material_ui: não usar `GoogleFonts.xTextTheme()`; montar com `GoogleFonts.inter(textStyle: ...)` (veja `app_theme.dart`).
- `√9!` = `(√9)!`; fatorial até 20!; comparação com tolerância 1e-9.
- Números resolvidos são guardados **por nível**.
- Não copiar o visual do Balatro (nada do redemoinho animado nem de louros); o fundo é nosso: curvas de nível.

## Preferências do Thales
- Respostas em português; commits em português, curtos, sem atribuição de IA (skill `commit-pr-style`).
- Nada de comentários óbvios no código; só os que explicam um porquê não visível.
- Pode discordar e dizer quando uma ideia é ruim.

## Ambiente
- Flutter 3.50 em `~/development/flutter` (PATH no `~/.zshrc`). Para web, o Chrome é o Chromium do Playwright (`CHROME_EXECUTABLE`).
- Rodar: `flutter run -d web-server --web-port 8080 --web-hostname localhost`.
- Para hot restart vindo de fora, rode com o stdin num FIFO (`tail -f fifo | flutter run ...`) e mande `R` para o FIFO.
- Testar visual: `playwright-core` + Chromium em `~/.cache/ms-playwright/chromium-1228`. O app é canvas; os cliques são por coordenada. Para posicionar uma peça, arrastar "chegando por cima" do tabuleiro.
- Firebase CLI logado como thaleslevs; `git remote origin` via SSH (`git@github.com:thaleslevs/ddm_emplake_reverse.git`).

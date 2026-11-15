# Plano de implementação inicial — Emplake (Flutter Web)

Prazo: **16/11/2026**. Hoje é 13/11, então restam cerca de 3 dias. Por isso a prioridade é cumprir **todos** os itens obrigatórios do professor com qualidade, e só depois aplicar o nosso "twist".

Fontes:
- `docs/engenharia-reversa-emplake.md` (código decompilado + testes no navegador)
- spec por screenshots (colega)
- tech stack do livro (colega)
- enunciado do professor

**Regra de prioridade:** enunciado do professor > livro > jogo original.

---

## 1. Conferência das especificações

### Spec por screenshots × código real

| Ponto | Spec do colega | Realidade (código + navegador) | Decisão |
|---|---|---|---|
| Peças no Elementar | `+ − × ÷ ( ) =` | também `√ ∛ !` (descrição do jogo está errada) | irrelevante: usamos os níveis do professor |
| Intermediário | adiciona `** √ ∛ !` | adiciona `**` e `\| \|` | irrelevante: idem |
| Ao acertar | carrega nova placa automaticamente | mostra painel de vitória; "Próximo" só no Aleatório/Aventura | nosso app: painel + "Próximo" |
| Desafios | não visto | 45 desafios no código; trava no web | usar os 45 como casos de teste |
| Menu ⚙, vitória/erro, regras de avaliação | não visto | documentado | — |
| Ícone mudo com X vermelho, cores aproximadas | ✅ (complementa) | — | só referência; não copiar visual |
| Aventura: módulo/chão/teto comprados em par | ✅ | ✅ código confirma | ok |

**Conclusão:** a spec do colega acrescenta detalhes visuais. As regras e o comportamento vêm da engenharia reversa. Não há conflito que afete o nosso app.

### Stack do livro × exigências do professor

O professor exige coisas que **não estão** na lista do livro. Elas são obrigatórias:
- `curved_navigation_bar`
- renderizador LaTeX (`flutter_math_fork`)
- pacote de progress indicator customizado (`loading_animation_widget`)
- `flutter_localizations` + `intl` (gen-l10n oficial com ARB). `slang` seria "equivalente", mas o oficial é mais seguro na correção.
- **`firebase_ui_localizations`**: sem ele, as telas do firebase_ui_auth ficam só em inglês, e o professor pede "absolutamente todos os textos" traduzidos.

**Itens do livro que ficam de fora** (seria exagero para este trabalho): objectbox, Supabase/Cloudflare, http, FCM/OneSignal, RevenueCat, Isolate, Widgetbook, Mason, re_editor, Rive/Lottie, flutter_neumorphic (sem manutenção), Navigator 1.0 (o go_router é obrigatório).

**Itens do livro que usamos:** Riverpod (`Notifier`/`AsyncNotifier`/`FutureProvider`), go_router (`StatefulShellRoute`), shared_preferences, Firebase (Auth + firebase_ui_auth + Firestore + Hosting), FlexColorScheme, `MediaQuery.sizeOf`/`LayoutBuilder`, `Draggable`/`DragTarget` (opcional), flutter_animate.

### Pontos de atenção do enunciado (fáceis de perder)

1. **Entrega só de `.dart`.** Isso tem três consequências:
   - Os arquivos gerados pelo l10n precisam ficar dentro de `lib/`. Usar `l10n.yaml` com `output-dir: lib/l10n/gen` e `synthetic-package: false`.
   - As fontes vêm do `google_fonts` (sem assets).
   - O som não pode depender de arquivo de asset. Opções: tocar de uma URL ou gerar o tom em código.
2. **Níveis invertidos em relação ao original.** O **Fácil** tem todos os operadores e é o único que aceita divisão não inteira. Nos demais níveis, divisão não inteira gera **erro**.
3. "Números resolvidos": guardar **por nível**. Resolver 1234 no Fácil não conta como resolvido no Difícil, porque com menos operadores é outro desafio. Decisão nossa (13/11), documentar na ajuda.
4. Integrantes (página de login): **Caio Monteiro Arraes** e **Thales Leonardo Euler Vieira de Sousa**.
4. Tema inicial = tema do dispositivo (`ThemeMode.system`).
5. Navbar presente em **todas** as páginas após o login, com ícone de Configurações e botão de Ajuda (`showDialog`).
6. Página de login com os **nomes do grupo** e o **seletor de idioma com bandeiras**.

### O que você disse × o professor

| Você disse | Bate com o professor? |
|---|---|
| Não copiar a identidade visual | ✅ Mais que permitido: o professor **exige** interface única. |
| Animações suaves, sem flickering, mais fluido que o original | ✅ Animação é obrigatória e "qualidade muito alta" é exigida. |
| Preferir ferramentas do livro | ✅ desde que **não** substituam os pacotes que o professor exige (lista acima). |
| Plano sem exagero | ✅ Escopo abaixo = obrigatórios + 1 twist. |

---

## 2. Stack final (pubspec)

```
flutter_riverpod, go_router, shared_preferences,
firebase_core, firebase_auth, firebase_ui_auth, firebase_ui_oauth_google,
firebase_ui_localizations, cloud_firestore,
flutter_localizations (sdk), intl,
curved_navigation_bar, flutter_math_fork, loading_animation_widget,
flex_color_scheme, google_fonts, flutter_animate,
country_flags   (bandeiras; emoji de bandeira não renderiza no Chrome/Windows)
audioplayers    (opcional; som desligado por padrão)
```

Ambiente: **instalar o Flutter SDK, o Firebase CLI e o FlutterFire CLI** (nenhum está nesta máquina). Criar um projeto Firebase no plano Spark.

## 3. Arquitetura

```
lib/
  main.dart                     # Firebase.init, ProviderScope
  app.dart                      # MaterialApp.router (tema, locale, l10n delegates)
  core/
    router.dart                 # go_router + StatefulShellRoute + redirect de auth + restaura rota
    theme.dart                  # FlexColorScheme a partir das settings
  l10n/ app_pt.arb, app_en.arb, gen/*.dart (gerado)
  features/
    auth/login_page.dart        # SignInScreen (email + Google), nomes do grupo, idioma
    shell/shell_scaffold.dart   # CurvedNavigationBar (Jogar, Histórico, Ajuda, Config)
    help/help_dialog.dart
    settings/ settings_controller.dart, settings_page.dart
    game/
      domain/ token.dart, level.dart, parser.dart, evaluator.dart, latex.dart
      state/ game_controller.dart          # Notifier: tokens, cursor, resultado
      ui/ level_page.dart, game_page.dart, expression_board.dart, operator_palette.dart
    progress/
      progress_repository.dart  # Firestore
      history_page.dart         # FutureBuilder + loader customizado
```

## 4. Domínio do jogo (núcleo; fazer primeiro, com testes)

- **Tokens:** `digit(0-9)`, `+ − × ÷`, `**`, `√`, `∛`, `!`, `( )`, `|abre |fecha`, `⌊ ⌋`, `⌈ ⌉`, `=`. O módulo usa tokens de abertura e fechamento distintos, como no original, para evitar ambiguidade.
- **Níveis** (enum com os operadores permitidos e a flag `allowsFractionalDivision`):
  - Fácil: todos + `⌊⌋ ⌈⌉` + divisão fracionária
  - Intermediário: `+ − × ÷ ( ) √ ∛ ! ** | |`
  - Avançado: `+ − × ÷ ( ) √ ! | |`
  - Difícil: `+ − × ÷ ( ) | |`
- **Parser próprio (descida recursiva)**, sem eval de string. Isso já corrige vários bugs do original.
  ```
  equation := expr '=' expr
  expr     := term (('+'|'−') term)*
  term     := unary (('×'|'÷') unary)*
  unary    := '−' unary | power
  power    := postfix ('**' unary)?          # associativo à direita
  postfix  := prefix '!'*
  prefix   := ('√'|'∛') prefix | primary
  primary  := digit | '(' expr ')' | '|' expr '|' | '⌊' expr '⌋' | '⌈' expr '⌉'
  ```
- **Regras de validação:**
  - os 4 dígitos aparecem na ordem dada e não concatenam;
  - exatamente um `=`;
  - `√` de número negativo dá erro;
  - `!` só aceita inteiro ≥ 0, com limite (ex.: ≤ 20);
  - divisão por 0 dá erro;
  - divisão não inteira fora do Fácil dá erro;
  - a comparação usa tolerância de 1e-9.
- Os erros são tipados (`sealed class EvalError`), com mensagem traduzida na UI.
- **AST → LaTeX:** `\sqrt{}`, `\sqrt[3]{}`, `n!`, `a^{b}`, `\left| \right|`, `\lfloor \rfloor`, `\lceil \rceil`, `\div` ou `\frac`. Renderizado ao vivo **abaixo** da expressão.
- **Testes unitários:** os casos que validei no navegador (`√(8+1)=3**1`, `⌊7/2⌋=3*1`, `|1−4|=3*1`, `5/2=5/2` válido só no Fácil…) e os erros.

## 5. Interface (funcional agora, twist visual depois)

**Decidido (13/11): o arrastar é a interação principal.** A diferença em relação ao original está no visual e na fluidez:
- **Linha de expressão** com os 4 dígitos fixos. Peças de qualquer quantidade podem ser soltas antes, entre ou depois dos dígitos. Não existem lacunas fixas por símbolo.
- Durante o arrasto, o ponto de inserção **abre espaço animado** (as peças vizinhas se afastam). Isso é feito com `Draggable`/`DragTarget` + `AnimatedSlide`/`AnimatedContainer`. Para reordenar, arrasta-se a peça dentro da linha. Para remover, solta-se a peça fora da linha (ou dá-se um toque duplo).
- **`=` (dica do professor: "o sinal de = já pode ser colocado logo no início, já que ele sempre estará lá"):** o `=` **não** é um dispensador infinito na paleta. Ele é **uma peça única** que já existe desde o início, mas **fora** da expressão, num suporte próprio. O jogador só precisa arrastá-lo para o lugar certo. Assim nunca acontece "mais de um =" e **nenhuma posição é entregue** (não dá parte da resposta).
- Atalho de acessibilidade (opcional): tocar num operador insere na posição do último ponto tocado.
- A paleta mostra só os operadores do nível.
- Prévia LaTeX ao vivo abaixo da expressão.
- Botões: **Verificar**, **Limpar**, **Pular**.
- **Animação obrigatória:** ao verificar, as peças voam de volta para a paleta (flutter_animate, ou overlay com posições via `GlobalKey`). Feedback de acerto/erro com animação curta.
- **Fluidez sem flicker:**
  - `ref.watch(provider.select(...))` para rebuilds mínimos;
  - `const` widgets;
  - `ValueKey` por token;
  - `AnimatedSwitcher`/`AnimatedSize` em vez de trocar a árvore;
  - `RepaintBoundary` na prévia LaTeX.
- **Responsivo:** `LayoutBuilder` com breakpoints (celular em coluna; desktop com paleta ao lado) e `FittedBox` na linha da expressão.

## 6. Navegação e páginas

- `/login` fica fora do shell. O `redirect` do go_router olha o estado de auth (`authStateChanges` via StreamProvider).
- O shell (`StatefulShellRoute.indexedStack`) tem a CurvedNavigationBar com: **Jogar** (`/play`, escolha de nível → `/play/:level`), **Histórico** (`/history`), **Ajuda** (abre `showDialog`, não é rota) e **Configurações** (`/settings`).
- **Restaurar a página ao reabrir:** um listener do router salva `location` no SharedPreferences, e esse valor vira o `initialLocation` no boot (depois do auth). Fazer por último, como o professor sugere.

## 7. Configurações (Riverpod `Notifier` + SharedPreferences)

- Tema claro / escuro / sistema (padrão: sistema).
- Escala de fonte (`TextScaler`, por slider).
- Família de fonte (`google_fonts`: Roboto, EB Garamond, Inter (parecida com Helvetica), Lato, Merriweather).
- Cor semente (paleta de cores) e temas prontos (`FlexScheme` presets).
- Idioma (o mesmo estado do login).
- Som on/off (padrão **off**).

## 8. Firestore (sempre lido via FutureBuilder + LoadingAnimationWidget)

```
users/{uid}                     { displayName, totalScore, updatedAt }
users/{uid}/solved/{level}_{nnnn} { number, level, expression, latex, solvedAt }
```

- **Ao abrir um nível:** FutureBuilder carrega os resolvidos daquele nível e sorteia um número de 0000–9999 que **não** esteja resolvido.
- **Ao acertar:** grava o documento do número resolvido e incrementa a pontuação.
- **Histórico:** FutureBuilder lista os números resolvidos e mostra a fórmula em LaTeX.
- **Regras:** cada usuário lê e escreve só `users/{uid}/**` do próprio uid.
- **Deploy:** Firebase Hosting (`flutter build web`). Adicionar o domínio aos domínios autorizados do Google Sign-In.

## 9. Ordem de execução e divisão da dupla

| Etapa | Pessoa A (jogo) | Pessoa B (infra) |
|---|---|---|
| 1 | parser + avaliador + LaTeX + testes | setup Flutter/Firebase, projeto, flutterfire configure, pubspec |
| 2 | game_controller + tela de jogo (cursor, paleta, prévia LaTeX, verificar/limpar/pular) | auth + login (nomes, idioma, bandeiras), router + shell + navbar + ajuda |
| 3 | animação das peças + responsividade | l10n completa (ARB + firebase_ui_localizations), configurações/tema |
| 4 | integração Firestore (resolvidos, pontuação, histórico) | deploy Hosting, som opcional, restaurar rota |
| 5 | **twist visual** + polimento | revisão do checklist do professor |

## 10. Checklist do professor (revisado em 14/11)

- [x] 4 níveis com os operadores exatos; divisão fracionária só no Fácil (erro nos demais)
- [x] LaTeX abaixo da fórmula
- [x] interface única
- [x] som opcional (desligado por padrão), com volume separado para música e efeitos
- [x] web hospedada: https://emplake-ddm-6ab5b.web.app
- [x] firebase_ui_auth com e-mail/senha + Google
- [x] login com nomes do grupo e idioma com bandeiras
- [x] 100% dos textos em PT/EN via flutter_localizations (inclusive firebase_ui)
- [x] curved_navigation_bar em todas as páginas pós-login, com Configurações e Ajuda (showDialog)
- [x] configurações: tema claro/escuro, tamanho da fonte, tipo da fonte, cor semente, temas prontos, padrão do sistema
- [x] reabrir na última página (SharedPreferences)
- [x] Riverpod útil
- [x] go_router
- [x] animação
- [x] Firestore via FutureBuilder + progress indicator customizado
- [x] guarda os resolvidos e só sorteia não resolvidos
- [x] pular número
- [x] responsivo
- [x] entrega só de `.dart` funciona (l10n gerado em `lib/`, sem assets obrigatórios)

Extras: solver que só sorteia números com solução, pontuação por nível, loja com skins e efeitos, ranking geral por pontos ganhos.

## Fora do escopo inicial (ideias para o twist)

- Solver que garante número solúvel antes de sortear e que serve de **dica**. O original tem o painel de dicas, mas sem lógica.
- Modo Desafios com os 45 números do professor.
- Timer e Aventura.

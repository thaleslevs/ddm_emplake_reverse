# Emplake

Jogo de igualdades com 4 dígitos, feito em Flutter Web para a disciplina de Desenvolvimento para Dispositivos Móveis.

**Grupo:** Caio Monteiro Arraes e Thales Leonardo Euler Vieira de Sousa

**Jogar online:** https://emplake-ddm-6ab5b.web.app

## Como jogar

Arraste operadores para antes, entre ou depois dos 4 dígitos do número, sem mudar a ordem deles, até formar uma igualdade verdadeira. O `=` é uma peça só. Quanto mais difícil o nível, menos operadores estão disponíveis:

| Nível | Operadores | Pontos |
| --- | --- | --- |
| Fácil | `+ − × ÷ ( )`, `√ ∛ ! ^`, módulo, piso e teto; aceita divisão que não dá inteiro | 1 |
| Intermediário | `+ − × ÷ ( )`, `√ ∛ ! ^` e módulo | 2 |
| Avançado | `+ − × ÷ ( )`, `√ !` e módulo | 3 |
| Difícil | `+ − × ÷ ( )` e módulo | 5 |

Fora do Fácil, toda divisão precisa dar um número inteiro.

A fórmula aparece em LaTeX logo abaixo da expressão. Os números resolvidos ficam salvos na conta e não voltam a ser sorteados; o sorteio só escolhe números que têm solução.

## O que o trabalho pede e onde está

- **Login** (`lib/features/auth/`): `firebase_ui_auth` com e-mail/senha e Google, nomes do grupo e seletor de idioma com bandeiras.
- **Idiomas** (`lib/l10n/`): português e inglês em todos os textos, inclusive os do `firebase_ui`. O código gerado já está em `lib/l10n/gen/`.
- **Navegação** (`lib/app/`): `go_router` e `curved_navigation_bar` em todas as páginas depois do login: Jogar, Placar, Loja, Ajuda (`showDialog`) e Configurações. O app reabre na última página visitada (`SharedPreferences`).
- **Configurações** (`lib/features/settings/`): modo claro/escuro/sistema, tamanho e tipo da fonte, cor semente, temas prontos, música e efeitos sonoros (desligados por padrão) com volume separado.
- **Estado:** Riverpod (`lib/features/*/state/`, `lib/core/settings/`).
- **Firestore:** carregado com `FutureBuilder` e indicador de progresso customizado (`lib/app/account_gate.dart`, `lib/features/ranking/scores_page.dart`).
- **Pular número**, layout responsivo e animações (peças, reações dos palhaços, efeitos de acerto).

Extras: pontuação por nível, loja com skins para os palhaços e efeitos de acerto, e ranking geral pelos pontos ganhos (gastar na loja não muda a posição).

## Rodar localmente

Com o Flutter 3.50 (Dart 3.14) ou mais novo:

```bash
flutter pub get
flutter run -d chrome
```

Os testes ficam em `test/`:

```bash
flutter test
```

## Entrega só com os arquivos `.dart`

O app não usa assets próprios: fontes, sons, música e desenhos são gerados pelo código. Para rodar só com a pasta `lib/`, crie um projeto Flutter, substitua a `lib/` e adicione as dependências:

```bash
flutter pub add flutter_riverpod go_router shared_preferences firebase_core firebase_auth firebase_ui_auth firebase_ui_oauth_google firebase_ui_localizations cloud_firestore intl curved_navigation_bar flutter_math_fork loading_animation_widget flex_color_scheme google_fonts flutter_animate country_flags web "flutter_localizations:{\"sdk\":\"flutter\"}"
```

Para o login com Google rodar fora do site publicado, o endereço local precisa estar liberado no Firebase (por padrão, `localhost:8080` e `localhost:8090`).

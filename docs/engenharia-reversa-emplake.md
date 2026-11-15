# Emplake — Engenharia reversa (parte Claude Code)

Fonte: https://www.cyan-lang.org/emplake/ — analisado em 2026-11-13.

**Como foi obtido:** o site é um export Web do **Godot 3.5.3**. Baixei o `index.pck`, extraí todos os arquivos e decompilei os scripts GDScript (`.gdc`, bytecode v13) de volta para código legível. Depois rodei o jogo em navegador headless (Playwright) para confirmar o comportamento.
Então as regras abaixo vêm do **código real** do jogo, e não de suposição. Onde algo só foi deduzido do código e não testado no navegador, está marcado *(código)*.

Material bruto (scripts decompilados, cenas `.tscn`, screenshots e as ferramentas `unpck.py`/`gdc.py`): material local, fora do repositório, porque o jogo original é do professor.

---

## 1. Visão geral

- Tema: **placa de carro Mercosul brasileira**. Splash com a placa "BRASIL / 3MPL4K3" e o texto "Toque na tela para prosseguir...". Fonte: GL-Nummernschild (fonte de placa) e Xolonium.
- Durante o jogo, a "placa" mostra no topo um **município brasileiro aleatório** ("UF - Cidade", tirado de uma lista com os 5570 municípios) e embaixo os **4 dígitos**.
- Objetivo: inserir operadores **entre/ao redor** dos 4 dígitos (sem mudar a ordem deles) para formar uma **igualdade verdadeira**. Exemplo: `2 3 3 3` → `2 * 3 = 3 + 3`.
- A **música de fundo começa tocando sozinha** (`autoplay = true`). É o erro de usabilidade que o professor cita. Existe um botão de mudo (ícone de alto-falante).

## 2. Fluxo de telas

```
Splash ──toque──► Menu principal (Modo + Descrição + "Selecionar" + mudo)
                    ├─ Educacional ─► Jogo (números fixos 2333, só + - * /, sem timer)
                    ├─ Aleatório   ─► Tela Complexidade ─► Jogo (4 dígitos aleatórios)
                    ├─ Específico  ─► Tela Complexidade + campo "Escolha um número" ─► Jogo
                    ├─ Desafios    ─► Seleção de níveis (45 desafios)  ⚠ TRAVA no web
                    └─ Aventura    ─► Jogo (modo loja/dinheiro, sem timer)
```

**Menu principal:** dois painéis lado a lado. "MODO" tem radio buttons e "DESCRIÇÃO" mostra um texto dinâmico. Abaixo fica o botão "SELECIONAR". Descrições:
- Educacional: "Modo para aprender o funcionamento do jogo e como as operações funcionam"
- Aleatório: "Os numeros serão escolhidos de forma aleatoria"
- Específico: "Os numeros serão escolhidos pelo jogador"
- Desafios: "Conjunto de desafios com diferentes dificuldades"
- Aventura: "Modo sobrevivencia"

**Tela Complexidade:** "ELEMENTAR / INTERMEDIÁRIO / COMPLETO", com descrição, botão voltar (↩) e mudo. No modo Específico aparece um campo de 4 dígitos (aceita só `0-9`, no máximo 4). Se tiver menos de 4, mostra "Digite 4 numeros" em vermelho.

## 3. Tela de jogo (layout original)

- Canto superior esquerdo: ⚙ (abre o menu de pausa). No topo: "TEMPO: N" (30 s) e "SCORE: N". Há também um botão "Pausar timer 10s".
- Canto superior direito: 🧹 vassoura, que **limpa todos os operadores** e mantém os dígitos.
- Placa central com a cidade e os dígitos. À direita da placa fica o ▶ verde (verificar).
- Botão `=` separado, à direita.
- Linha 1 de peças: `+  -  ÷  *  √  ∛  !  **`
- Linha 2 de peças: `(  )  |→  ←|  ⌊  ⌋  ⌈  ⌉` (módulo de abertura e de fechamento são peças separadas; o mesmo vale para chão e teto).
- **Interação:** arrastar a peça do botão até a placa. A posição de inserção é decidida pelo **x da peça** em relação aos elementos que já estão lá, e tudo é recentralizado. Para reordenar, arrasta-se a peça dentro da placa. Para remover, arrasta-se a peça para fora da placa. Os dígitos não se movem.
- Limite: **13 elementos** no total (4 dígitos + 9 operadores) *(código)*.
- **Validação automática:** a cada peça colocada, o jogo avalia a expressão. Se ela for verdadeira, mostra a vitória sem precisar apertar ▶ (confirmado no navegador). O ▶ força a verificação e mostra o erro.
- **Menu ⚙ (pausa):** mudo, "TUTORIAL", "MENU PRINCIPAL" e "X". Enquanto está aberto, `Load.pause = true` e as peças ficam travadas.
- **Tela de vitória (verde):** "PONTUAÇÃO: N", "A igualdade está correta: <valor>" (no web o texto aparece **cortado**), "Voltar ao menu" e "Próximo" (só nos modos Aleatório e Aventura).
- **Tela de erro (vermelha):** "ESQUERDA DO IGUAL: <msg>", "DIREITA DO IGUAL: <msg>" e "FECHAR MENSAGEM".
- **Tutorial (popup):** explica o objetivo com o exemplo `3 * 2 = 3 + 3`. Diz para arrastar as peças, que arrastar para fora remove a peça, que a seta verde testa a resposta e que, se a resposta estiver correta, o jogo avisa sozinho.
- Existe na cena um painel de **Dicas** ("Mostrar um resultado possível", "Completar primeira metade", "Completar segunda metade") **sem lógica implementada**. Também existe um ícone de lâmpada (`lamapada_acesa/apagada.png`). É um recurso incompleto e pode virar ideia para o nosso app.

## 4. Operadores — IDs internos e complexidade

| id | peça(s) | símbolo interno | complexidade original |
|---|---|---|---|
| 0 | + | `+` | 0 |
| 1 | − | `-` | 0 |
| 2 | ÷ | `/` | 0 |
| 3 | × | `*` | 0 |
| 4 | ** (potência) | `^` | 1 |
| 5 | √ | `R` | 0 |
| 6 | ! | `!` | 0 |
| 7 | ( ) | `(` `)` | 0 |
| 8 | \| \| módulo | `\|` (abre) / `I` (fecha) | 1 |
| 9 | ⌊ ⌋ chão e ⌈ ⌉ teto | `{` `}` / `[` `]` | 2 |
| 10 | ∛ | `C` | 0 |
| 11 | = | `=` | sempre visível |

Uma peça aparece se `dificuldade >= complexidade`. Com Elementar=0, Intermediário=1 e Completo=2:
- **Elementar:** `+ − × ÷ ( ) √ ∛ ! =` *(código)*. A descrição diz "apenas os sinais primários +, -, *, / e parênteses", o que **contradiz** a lógica.
- **Intermediário:** acrescenta `**` e `| |`.
- **Completo:** acrescenta `⌊⌋` e `⌈⌉`. Confirmado no navegador: aparecem todas as 17 peças.

> ⚠ **O professor muda isso.** O enunciado tem **4 níveis** com a lógica invertida: o "Fácil" tem **todos** os operadores e o "Difícil" tem só `+ − × ÷ ( ) | |`. Além disso, só o Fácil aceita divisão não inteira. O original aceita divisão não inteira em todos os níveis. Seguimos o enunciado, não o original.

## 5. Regras de avaliação (de `AreaNumeros.gd`)

1. A expressão é a sequência de tokens. **Exatamente um `=`.** As mensagens de erro são:
   - nenhum `=` → "Expressão sem ="
   - mais de um `=` → "Mais de um igual na operação"
   - `=` no fim → "Igual em local errado"
2. Cada lado é avaliado separadamente. A igualdade vale se `str(lado1) == str(lado2)`, ou seja, compara os resultados **como string de float**. Isso é frágil (problema de ponto flutuante). Nós vamos comparar com tolerância ou com racionais.
3. **Dígitos não concatenam:** dois números seguidos sem operador entre eles dão "Erro dois numeros sem operação". `2 3` nunca vira 23.
4. **Agrupadores** `( )`, `| |`, `⌊ ⌋`, `⌈ ⌉` são resolvidos recursivamente. Depois aplica-se `abs`, `floor` ou `ceil`. Erros:
   - fechar o tipo errado → "Erro usando X na hora errada"
   - não fechar → "Erro faltou fechar X"
5. **Unários prefixos** `√` e `∛` aplicam-se ao próximo número ou ao próximo grupo. `√` de negativo dá "Erro valor negativo na raiz". `∛` de negativo funciona (`-pow(|x|,1/3)`).
6. **`!` pós-fixo** aplica-se ao token anterior. Erros:
   - não inteiro ou negativo → "Erro na expressao durante !"
   - **n > 15** → "Overflow devido a ! muito grande"
   - `!` no início → "! usado na posição errada"
7. **`**`** usa o token anterior como base e o próximo número ou grupo como expoente. Isso é aplicado antes de `*` e `/` por substituição textual, e as regras de precedência são frágeis.
8. **Divisão** é sempre em float (`float(a)/b`).
9. Sinal unário (`-3`, `+3`) é aceito, porque o restante é passado ao `Expression` do Godot. Qualquer erro de parse gera "Erro de sintaxe".
10. A vitória mostra o valor de cada lado, por exemplo `6`.

### Testado no navegador (Específico + Completo, 2026-11-13)

| Dígitos | Expressão montada | Resultado | Pontuação exibida |
|---|---|---|---|
| 2333 | `2 * 3 = 3 + 3` | ✅ 6 | 201 |
| 8131 | `√ ( 8 + 1 ) = 3 ** 1` | ✅ 3 | 501 (√200 + 100 + **200, +1) |
| 3161 | `3 ! * 1 = 6 * 1` | ✅ 6 | 401 |
| 5252 | `5 / 2 = 5 / 2` | ✅ 2.5 (divisão não inteira aceita) | 201 |
| 7231 | `⌊ 7 / 2 ⌋ = 3 * 1` | ✅ 3 | 1 (o chão tira 200) |
| 1431 | `\| 1 - 4 \| = 3 * 1` | ✅ 3 | 201 (o módulo não pontua) |
| 8211 | `∛ 8 = …` | lado esquerdo = 2 ✅ | — |

- Erros vistos: "Erro dois numeros sem operação" e "Erro de sintaxe". O painel de erro mostra o valor do lado que deu certo (ex.: esquerda `6` e direita com erro).
- Bug: `= ÷ 2` (divisão logo depois do `=`) é avaliado como `2` em vez de dar erro. O código usa o índice `-1`, que no GDScript é o último elemento.
- No modo Específico, a tela de vitória **não** tem "Próximo", só "Voltar ao menu".

## 6. Pontuação e tempo (modos Aleatório e Específico)

- O timer começa em **30 s**. Quando chega a 0, `scoreBase -= 20`. "Pausar timer 10s" pausa o relógio por 10 s.
- O score é recalculado a cada mudança: **+100** por `+ − × ÷`, **+200** por `√ ** !`, **−200** por `⌊ ⌈`. `∛` e `| |` não pontuam (provável esquecimento).
- Na vitória, mostra `score + 1`. Se o score for negativo, mostra "0 devido ao tempo".
- Não há persistência: nada é salvo entre sessões, sem login e sem histórico.

## 7. Modos em detalhe

- **Aleatório (0):** 4 dígitos aleatórios de 0 a 9, que **podem ser insolúveis** (não há checagem). "Próximo" gera outro número.
- **Específico (1):** o jogador digita os 4 dígitos.
- **Desafios (2):** 45 desafios fixos, divididos em Fácil 1–15, Médio 16–30 e Difícil 31–45. Cada um tem o seu **conjunto de operadores permitidos**. O progresso seria salvo em `res://Desafios.txt` (`NN=1`), mas **o arquivo não está no pacote**: o loop `while not f.eof_reached()` sobre um arquivo que não abriu **congela a página**. Confirmado por nós dois.
- **Educacional (3):** números `2333`, só `+ − × ÷` e `=`, sem timer e com tutorial aberto. O código referencia `Load.tutorialNum`, `numerosTutorial` e `operacoesTutorial`, que **não existem** em `Load.gd`. Por isso é provável que dê erro ao avançar *(código)*. Existe também uma cena `ModoAprendizado` (Básico 1–3, Nível 1–3 × 3) que não está ligada ao menu.
- **Aventura (4):** "modo sobrevivência" com **dinheiro em vez de tempo**. Começa com 2000$. `+ − × ÷ ( ) =` são livres. As peças `√ ∛ ! ** | | ⌊⌋ ⌈⌉` custam **1000$** cada e são de uso limitado (ficam cinza quando esgotam). Cada vitória dá +1000$ e score +1. O comportamento das peças compradas entre rodadas tem bugs.

### Lista dos 45 desafios (dígitos + operadores permitidos)

Ordem do vetor: `[+, −, ÷, ×, **, √, !, ( ), | |, ⌊⌋⌈⌉, ∛]`. O `=` é sempre permitido.

| # | dígitos | operadores |
|---|---|---|
| 1 | 3210 | + − |
| 2 | 2328 | + − ÷ × |
| 3 | 8222 | + − ÷ × |
| 4 | 0977 | + − ÷ × |
| 5 | 3317 | todos |
| 6 | 6105 | + − ÷ × |
| 7 | 1582 | + − ÷ × |
| 8 | 2256 | + − ÷ × |
| 9 | 2290 | + − ÷ × |
| 10 | 2569 | + − ÷ × |
| 11 | 3193 | + − ÷ × |
| 12 | 3444 | + − ÷ × |
| 13 | 4335 | + − ÷ × |
| 14 | 4366 | + − ÷ × |
| 15 | 9854 | + − ÷ × |
| 16 | 1417 | + − ÷ × ** |
| 17 | 1435 | + − ÷ × ** ( ) |
| 18 | 1464 | + − ÷ × √ |
| 19 | 1497 | + − ÷ × √ |
| 20 | 1502 | ** ! |
| 21 | 2140 | + − ÷ × √ |
| 22 | 2235 | + − ÷ × √ \|\| |
| 23 | 2292 | + − ÷ × √ |
| 24 | 2336 | + − ÷ × √ ! |
| 25 | 4249 | + − ÷ × √ |
| 26 | 4247 | + − ÷ × ! ( ) |
| 27 | 4170 | + − ÷ × ! ( ) |
| 28 | 4156 | + − ÷ × ! ( ) |
| 29 | 4258 | + − ÷ × ! ( ) |
| 30 | 4294 | + − ÷ × √ |
| 31 | 0575 | + − ÷ × √ ! \|\| |
| 32 | 0657 | + − ÷ × ! ( ) |
| 33 | 0757 | + − ÷ × ! ( ) ∛ |
| 34 | 0838 | + − ÷ × ** ! ( ) ∛ |
| 35 | 2194 | + − ÷ × ** √ ( ) |
| 36 | 1849 | + − ÷ × √ ! ( ) |
| 37 | 2308 | + − ÷ × √ ! ( ) |
| 38 | 2335 | + − ÷ × √ ! ( ) |
| 39 | 2364 | + − × √ ! ( ) (sem ÷) |
| 40 | 3268 | + − ÷ × √ ! ( ) |
| 41 | 3384 | + − ÷ × ** √ ! ( ) |
| 42 | 3561 | + − ÷ × ! |
| 43 | 3659 | + − ÷ × √ ! |
| 44 | 3747 | + − ÷ × ⌊⌋⌈⌉ |
| 45 | 3868 | + − ÷ × ** √ ! ( ) |

Esses desafios podem servir de banco de "números difíceis" e de casos de teste para o nosso avaliador.

## 8. Bugs e problemas de UX do original (para não repetir)

1. A música toca sozinha ao abrir (o professor cita isso).
2. O modo Desafios congela o navegador por causa do arquivo de progresso que falta.
3. O modo Educacional referencia variáveis que não existem e não tem trilha de níveis ligada.
4. O texto da vitória aparece cortado ("A igualdade está correta").
5. A descrição do nível Elementar diz uma coisa e o jogo mostra outra.
6. A igualdade é comparada por string de float, então há falsos negativos possíveis (ex.: `0.1+0.2`).
7. O modo Aleatório pode sortear números sem solução, e não existe botão "pular" (o professor exige um).
8. Não há persistência, login, idioma, tema nem acessibilidade. A UI tem tamanho fixo de 1280×720 com a escala do Godot.
9. Não há fórmula renderizada (o professor exige LaTeX abaixo da expressão).
10. O painel de dicas existe, mas não funciona.
11. A pontuação é inconsistente (`∛` e `| |` não contam).

## 9. Mapa: enunciado do professor × original

| Requisito do professor | Original tem? | Observação |
|---|---|---|
| 4 níveis Fácil/Intermediário/Avançado/Difícil com estes operadores | ❌ (3 níveis, lógica invertida) | Implementar como no enunciado |
| Divisão não inteira só no Fácil, erro nos demais | ❌ | Avaliador precisa saber o nível |
| LaTeX abaixo da fórmula | ❌ | `flutter_math_fork` ou `flutter_tex` |
| Interface única (não arrastar igual ao original) | — | Nosso "twist" visual |
| `=` já posicionado | ❌ | Dica do professor |
| Som opcional (desligado por padrão) | ❌ | |
| Web (Netlify/GitHub Pages/Vercel/Firebase Hosting) | ✅ (Godot web) | |
| Login firebase_ui_auth (e-mail/senha + Google) | ❌ | |
| Nomes do grupo e idioma com bandeiras no login | ❌ | |
| i18n completo com flutter_localizations (PT/EN) | ❌ | |
| Navbar curved_navigation_bar com Configurações e Ajuda (showDialog) | ❌ | |
| Configurações: claro/escuro, tamanho da fonte, tipo da fonte, cor semente, temas prontos, padrão do sistema | ❌ | |
| Voltar à última página ao reabrir (SharedPreferences) | ❌ | Deixar por último |
| Riverpod, go_router | — | |
| Animação (peças voltam ao lugar depois de verificar) | parcial (peças se reposicionam) | |
| Firestore com FutureBuilder e indicador de progresso customizado | ❌ | |
| Guardar números resolvidos e sortear só os não resolvidos | ❌ | |
| Pular número | ❌ | |
| Responsivo | ❌ (escala fixa) | |

## 10. Pontos para cruzar com o prompt do colega (screenshots)

- Confirmar se ele viu algo no **Específico** ou na **Aventura** que não está aqui. O fluxo de compra de peças entre rodadas é o ponto mais confuso.
- Conferir o texto completo do **Tutorial do menu ⚙** (lista de símbolos). No pacote, `TutorialTxt.tres` só tem `+` e o começo de `-`, então o tutorial por símbolo está incompleto no original.
- Se ele listou o Elementar como "só + − × ÷ ( )", o código mostra que `√ ∛ !` também aparecem. Vale testar no navegador para confirmar.
- Os screenshots dele devem bater com os do material local (fora do repositório).

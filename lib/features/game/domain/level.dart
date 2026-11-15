import 'token.dart';

enum Level {
  easy(
    allowsFractionalDivision: true,
    operators: {
      ..._basic,
      TokenKind.sqrt,
      TokenKind.cbrt,
      TokenKind.factorial,
      TokenKind.power,
      ..._abs,
      TokenKind.floorOpen,
      TokenKind.floorClose,
      TokenKind.ceilOpen,
      TokenKind.ceilClose,
    },
  ),
  intermediate(
    operators: {..._basic, TokenKind.sqrt, TokenKind.cbrt, TokenKind.factorial, TokenKind.power, ..._abs},
  ),
  advanced(operators: {..._basic, TokenKind.sqrt, TokenKind.factorial, ..._abs}),
  hard(operators: {..._basic, ..._abs});

  const Level({required this.operators, this.allowsFractionalDivision = false});

  final Set<TokenKind> operators;
  final bool allowsFractionalDivision;

  bool allows(TokenKind kind) =>
      kind == TokenKind.digit || kind == TokenKind.equals || operators.contains(kind);

  /// Pontos por número resolvido: quanto menos operadores, mais difícil.
  int get points => switch (this) {
    Level.easy => 1,
    Level.intermediate => 2,
    Level.advanced => 3,
    Level.hard => 5,
  };
}

const _basic = {
  TokenKind.plus,
  TokenKind.minus,
  TokenKind.times,
  TokenKind.divide,
  TokenKind.parenOpen,
  TokenKind.parenClose,
};

const _abs = {TokenKind.absOpen, TokenKind.absClose};

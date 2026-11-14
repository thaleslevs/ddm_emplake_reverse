import 'token.dart';

/// Difficulty levels exactly as required by the assignment.
///
/// Note the inversion compared with the original game: the easiest level
/// offers the most operators, and only it accepts non-integer division.
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
    operators: {
      ..._basic,
      TokenKind.sqrt,
      TokenKind.cbrt,
      TokenKind.factorial,
      TokenKind.power,
      ..._abs,
    },
  ),
  advanced(
    operators: {..._basic, TokenKind.sqrt, TokenKind.factorial, ..._abs},
  ),
  hard(operators: {..._basic, ..._abs});

  const Level({required this.operators, this.allowsFractionalDivision = false});

  /// Operators available in the palette (the digits and `=` are always present).
  final Set<TokenKind> operators;
  final bool allowsFractionalDivision;

  bool allows(TokenKind kind) =>
      kind == TokenKind.digit || kind == TokenKind.equals || operators.contains(kind);
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

/// Kinds of pieces the player can place on the board.
///
/// Opening and closing delimiters are distinct kinds (as in the original
/// game) so `|a| - |b|` is never ambiguous.
enum TokenKind {
  digit,
  plus,
  minus,
  times,
  divide,
  power,
  sqrt,
  cbrt,
  factorial,
  parenOpen,
  parenClose,
  absOpen,
  absClose,
  floorOpen,
  floorClose,
  ceilOpen,
  ceilClose,
  equals;

  /// Plain-text symbol shown on the piece.
  String get symbol => switch (this) {
        TokenKind.digit => '#',
        TokenKind.plus => '+',
        TokenKind.minus => '−',
        TokenKind.times => '×',
        TokenKind.divide => '÷',
        TokenKind.power => '**',
        TokenKind.sqrt => '√',
        TokenKind.cbrt => '∛',
        TokenKind.factorial => '!',
        TokenKind.parenOpen => '(',
        TokenKind.parenClose => ')',
        TokenKind.absOpen => '|',
        TokenKind.absClose => '|',
        TokenKind.floorOpen => '⌊',
        TokenKind.floorClose => '⌋',
        TokenKind.ceilOpen => '⌈',
        TokenKind.ceilClose => '⌉',
        TokenKind.equals => '=',
      };

  bool get isOpener => switch (this) {
        TokenKind.parenOpen ||
        TokenKind.absOpen ||
        TokenKind.floorOpen ||
        TokenKind.ceilOpen =>
          true,
        _ => false,
      };

  bool get isCloser => switch (this) {
        TokenKind.parenClose ||
        TokenKind.absClose ||
        TokenKind.floorClose ||
        TokenKind.ceilClose =>
          true,
        _ => false,
      };

  /// Closing kind matching an opener.
  TokenKind? get closer => switch (this) {
        TokenKind.parenOpen => TokenKind.parenClose,
        TokenKind.absOpen => TokenKind.absClose,
        TokenKind.floorOpen => TokenKind.floorClose,
        TokenKind.ceilOpen => TokenKind.ceilClose,
        _ => null,
      };

  /// True when a token of this kind can start an operand.
  bool get startsOperand =>
      this == TokenKind.digit ||
      this == TokenKind.sqrt ||
      this == TokenKind.cbrt ||
      isOpener;
}

/// One piece on the board. [id] is unique per placed piece so the UI can
/// keep stable keys while pieces move around.
class Token {
  const Token(this.kind, {required this.id, this.value})
      : assert(kind != TokenKind.digit || value != null);

  const Token.digit(int this.value, {required this.id})
      : kind = TokenKind.digit;

  final TokenKind kind;
  final String id;

  /// Digit value (0-9) when [kind] is [TokenKind.digit].
  final int? value;

  String get symbol => kind == TokenKind.digit ? '$value' : kind.symbol;

  @override
  String toString() => symbol;

  @override
  bool operator ==(Object other) =>
      other is Token && other.id == id && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(id, kind, value);
}

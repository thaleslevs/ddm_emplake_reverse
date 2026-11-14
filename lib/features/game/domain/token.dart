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
    TokenKind.absOpen => '|x',
    TokenKind.absClose => 'x|',
    TokenKind.floorOpen => '⌊',
    TokenKind.floorClose => '⌋',
    TokenKind.ceilOpen => '⌈',
    TokenKind.ceilClose => '⌉',
    TokenKind.equals => '=',
  };

  bool get isOpener => switch (this) {
    TokenKind.parenOpen || TokenKind.absOpen || TokenKind.floorOpen || TokenKind.ceilOpen => true,
    _ => false,
  };

  bool get isCloser => switch (this) {
    TokenKind.parenClose || TokenKind.absClose || TokenKind.floorClose || TokenKind.ceilClose => true,
    _ => false,
  };

  TokenKind? get closer => switch (this) {
    TokenKind.parenOpen => TokenKind.parenClose,
    TokenKind.absOpen => TokenKind.absClose,
    TokenKind.floorOpen => TokenKind.floorClose,
    TokenKind.ceilOpen => TokenKind.ceilClose,
    _ => null,
  };

  bool get startsOperand =>
      this == TokenKind.digit || this == TokenKind.sqrt || this == TokenKind.cbrt || isOpener;
}

class Token {
  const Token(this.kind, {required this.id, this.value}) : assert(kind != TokenKind.digit || value != null);

  const Token.digit(int this.value, {required this.id}) : kind = TokenKind.digit;

  final TokenKind kind;
  final String id;

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

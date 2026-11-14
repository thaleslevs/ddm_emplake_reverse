import 'errors.dart';
import 'expression.dart';
import 'parser.dart';
import 'token.dart';

/// LaTeX for a parsed equation, e.g. `√(8+1) = 3**1` → `\sqrt{8 + 1} = 3^{1}`.
String equationToLatex(Equation eq) => '${exprToLatex(eq.left)} = ${exprToLatex(eq.right)}';

String exprToLatex(Expr e) => switch (e) {
      Num(:final value) => '$value',
      Negate(:final operand) => '-${exprToLatex(operand)}',
      Binary(:final op, :final left, :final right) =>
        '${exprToLatex(left)} ${_op(op)} ${exprToLatex(right)}',
      Power(:final base, :final exponent) =>
        '${_powerBase(base)}^{${_unwrapParen(exponent)}}',
      Root(kind: RootKind.square, :final operand) => '\\sqrt{${_unwrapParen(operand)}}',
      Root(kind: RootKind.cube, :final operand) => '\\sqrt[3]{${_unwrapParen(operand)}}',
      Factorial(:final operand) => '${exprToLatex(operand)}!',
      Group(:final kind, :final inner) => _group(kind, exprToLatex(inner)),
    };

String _op(BinaryOp op) => switch (op) {
      BinaryOp.add => '+',
      BinaryOp.subtract => '-',
      BinaryOp.multiply => '\\times',
      BinaryOp.divide => '\\div',
    };

/// A radical or exponent already groups visually, so `√(8+1)` drops the
/// parentheses, as in the assignment's example.
String _unwrapParen(Expr e) =>
    e is Group && e.kind == GroupKind.paren ? exprToLatex(e.inner) : exprToLatex(e);

/// `3!^2` would be ambiguous; wrap such bases in braces.
String _powerBase(Expr base) =>
    base is Factorial ? '{${exprToLatex(base)}}' : exprToLatex(base);

String _group(GroupKind kind, String inner) => switch (kind) {
      GroupKind.paren => '\\left( $inner \\right)',
      GroupKind.abs => '\\left| $inner \\right|',
      GroupKind.floor => '\\left\\lfloor $inner \\right\\rfloor',
      GroupKind.ceil => '\\left\\lceil $inner \\right\\rceil',
    };

/// Live preview for any board state, including incomplete ones.
///
/// Each side of `=` is rendered structurally when it parses; otherwise its
/// pieces are rendered one by one, so the preview never disappears while
/// the player is still building.
String boardToLatex(List<Token> tokens) {
  if (tokens.isEmpty) return '';
  final equalsAt = tokens.indexWhere((t) => t.kind == TokenKind.equals);
  final singleEquals =
      equalsAt >= 0 && tokens.lastIndexWhere((t) => t.kind == TokenKind.equals) == equalsAt;
  if (!singleEquals) return _raw(tokens);

  final left = _side(tokens.sublist(0, equalsAt), 0);
  final right = _side(tokens.sublist(equalsAt + 1), equalsAt + 1);
  return [left, '=', right].where((s) => s.isNotEmpty).join(' ');
}

String _side(List<Token> tokens, int offset) {
  if (tokens.isEmpty) return '';
  try {
    return exprToLatex(SideParser(tokens, offset: offset).parse());
  } on EquationError {
    return _raw(tokens);
  }
}

String _raw(List<Token> tokens) => tokens.map(_tokenLatex).join(' ');

String _tokenLatex(Token t) => switch (t.kind) {
      TokenKind.digit => '${t.value}',
      TokenKind.plus => '+',
      TokenKind.minus => '-',
      TokenKind.times => '\\times',
      TokenKind.divide => '\\div',
      TokenKind.power => '{\\ast\\ast}',
      TokenKind.sqrt => '\\surd',
      TokenKind.cbrt => '\\sqrt[3]{\\,}',
      TokenKind.factorial => '!',
      TokenKind.parenOpen => '(',
      TokenKind.parenClose => ')',
      TokenKind.absOpen || TokenKind.absClose => '|',
      TokenKind.floorOpen => '\\lfloor',
      TokenKind.floorClose => '\\rfloor',
      TokenKind.ceilOpen => '\\lceil',
      TokenKind.ceilClose => '\\rceil',
      TokenKind.equals => '=',
    };

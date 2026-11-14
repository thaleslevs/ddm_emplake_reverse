import 'errors.dart';
import 'expression.dart';
import 'token.dart';

class SideParser {
  SideParser(this._tokens, {this.offset = 0});

  final List<Token> _tokens;

  final int offset;

  int _pos = 0;

  Expr parse() {
    final expr = _expr();
    if (!_atEnd) throw _unexpectedAfterOperand();
    return expr;
  }

  bool get _atEnd => _pos >= _tokens.length;
  TokenKind? get _peek => _atEnd ? null : _tokens[_pos].kind;
  int get _here => offset + (_atEnd ? _tokens.length - 1 : _pos);

  EquationError _unexpectedAfterOperand() {
    final kind = _tokens[_pos].kind;
    if (kind.isCloser) return UnexpectedCloser(kind, tokenIndex: _here);
    return MissingOperator(tokenIndex: _here);
  }

  Expr _expr() {
    var left = _term();
    while (_peek == TokenKind.plus || _peek == TokenKind.minus) {
      final at = _here;
      final op = _tokens[_pos++].kind == TokenKind.plus ? BinaryOp.add : BinaryOp.subtract;
      left = Binary(op, left, _term(), at);
    }
    return left;
  }

  Expr _term() {
    var left = _unary();
    while (_peek == TokenKind.times || _peek == TokenKind.divide) {
      final at = _here;
      final op = _tokens[_pos++].kind == TokenKind.times ? BinaryOp.multiply : BinaryOp.divide;
      left = Binary(op, left, _unary(), at);
    }
    return left;
  }

  Expr _unary() {
    if (_peek == TokenKind.minus) {
      final at = _here;
      _pos++;
      return Negate(_unary(), at);
    }
    return _power();
  }

  Expr _power() {
    final base = _postfix();
    if (_peek == TokenKind.power) {
      final at = _here;
      _pos++;
      return Power(base, _unary(), at);
    }
    return base;
  }

  Expr _postfix() {
    var expr = _prefix();
    while (_peek == TokenKind.factorial) {
      expr = Factorial(expr, _here);
      _pos++;
    }
    return expr;
  }

  Expr _prefix() {
    final kind = _peek;
    if (kind == TokenKind.sqrt || kind == TokenKind.cbrt) {
      final at = _here;
      _pos++;
      return Root(kind == TokenKind.sqrt ? RootKind.square : RootKind.cube, _prefix(), at);
    }
    return _primary();
  }

  Expr _primary() {
    if (_atEnd) throw MissingOperand(tokenIndex: _here);
    final token = _tokens[_pos];
    final at = _here;
    final kind = token.kind;

    if (kind == TokenKind.digit) {
      _pos++;
      return Num(token.value!, at);
    }

    if (kind.isOpener) {
      _pos++;
      final inner = _expr();
      if (_atEnd) throw UnclosedGroup(kind, tokenIndex: at);
      final next = _tokens[_pos].kind;
      if (next == kind.closer) {
        _pos++;
        return Group(_groupKind(kind), inner, at);
      }
      throw _unexpectedAfterOperand();
    }

    if (kind.isCloser) throw UnexpectedCloser(kind, tokenIndex: at);
    if (kind == TokenKind.factorial) throw MisplacedFactorial(tokenIndex: at);
    throw MissingOperand(tokenIndex: at);
  }

  static GroupKind _groupKind(TokenKind opener) => switch (opener) {
    TokenKind.absOpen => GroupKind.abs,
    TokenKind.floorOpen => GroupKind.floor,
    TokenKind.ceilOpen => GroupKind.ceil,
    _ => GroupKind.paren,
  };
}

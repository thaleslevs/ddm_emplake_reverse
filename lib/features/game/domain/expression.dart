sealed class Expr {
  const Expr(this.tokenIndex);

  final int tokenIndex;
}

final class Num extends Expr {
  const Num(this.value, super.tokenIndex);
  final int value;
}

final class Negate extends Expr {
  const Negate(this.operand, super.tokenIndex);
  final Expr operand;
}

enum BinaryOp { add, subtract, multiply, divide }

final class Binary extends Expr {
  const Binary(this.op, this.left, this.right, super.tokenIndex);
  final BinaryOp op;
  final Expr left;
  final Expr right;
}

final class Power extends Expr {
  const Power(this.base, this.exponent, super.tokenIndex);
  final Expr base;
  final Expr exponent;
}

enum RootKind { square, cube }

final class Root extends Expr {
  const Root(this.kind, this.operand, super.tokenIndex);
  final RootKind kind;
  final Expr operand;
}

final class Factorial extends Expr {
  const Factorial(this.operand, super.tokenIndex);
  final Expr operand;
}

enum GroupKind { paren, abs, floor, ceil }

final class Group extends Expr {
  const Group(this.kind, this.inner, super.tokenIndex);
  final GroupKind kind;
  final Expr inner;
}

class Equation {
  const Equation(this.left, this.right);
  final Expr left;
  final Expr right;
}

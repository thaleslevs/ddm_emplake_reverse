import 'package:emplake/features/game/domain/errors.dart';
import 'package:emplake/features/game/domain/judge.dart';
import 'package:emplake/features/game/domain/latex.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/token.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a board from space-separated symbols.
/// Absolute value uses `|<` (open) and `>|` (close).
List<Token> board(String source) {
  var i = 0;
  Token t(TokenKind k) => Token(k, id: '${i++}');
  return [
    for (final s in source.split(' ').where((s) => s.isNotEmpty))
      switch (s) {
        '+' => t(TokenKind.plus),
        '-' => t(TokenKind.minus),
        '*' => t(TokenKind.times),
        '/' => t(TokenKind.divide),
        '**' => t(TokenKind.power),
        '√' => t(TokenKind.sqrt),
        '∛' => t(TokenKind.cbrt),
        '!' => t(TokenKind.factorial),
        '(' => t(TokenKind.parenOpen),
        ')' => t(TokenKind.parenClose),
        '|<' => t(TokenKind.absOpen),
        '>|' => t(TokenKind.absClose),
        '⌊' => t(TokenKind.floorOpen),
        '⌋' => t(TokenKind.floorClose),
        '⌈' => t(TokenKind.ceilOpen),
        '⌉' => t(TokenKind.ceilClose),
        '=' => t(TokenKind.equals),
        _ => Token.digit(int.parse(s), id: '${i++}'),
      },
  ];
}

List<int> digitsOf(List<Token> b) => [
      for (final t in b)
        if (t.kind == TokenKind.digit) t.value!,
    ];

Verdict check(String source, {Level level = Level.easy, List<int>? digits}) {
  final b = board(source);
  return judge(b, digits: digits ?? digitsOf(b), level: level);
}

Matcher isCorrect(num value) =>
    isA<Correct>().having((c) => c.value, 'value', closeTo(value, 1e-9));

Matcher isInvalid<E extends EquationError>() =>
    isA<Invalid>().having((v) => v.error, 'error', isA<E>());

void main() {
  group('cases verified in the original game (browser)', () {
    test('2 * 3 = 3 + 3', () => expect(check('2 * 3 = 3 + 3'), isCorrect(6)));
    test('√(8+1) = 3**1', () => expect(check('√ ( 8 + 1 ) = 3 ** 1'), isCorrect(3)));
    test('3! * 1 = 6 * 1', () => expect(check('3 ! * 1 = 6 * 1'), isCorrect(6)));
    test('5/2 = 5/2', () => expect(check('5 / 2 = 5 / 2'), isCorrect(2.5)));
    test('⌊7/2⌋ = 3*1', () => expect(check('⌊ 7 / 2 ⌋ = 3 * 1'), isCorrect(3)));
    test('|1-4| = 3*1', () => expect(check('|< 1 - 4 >| = 3 * 1'), isCorrect(3)));
    test('∛8 = 2*1*1', () => expect(check('∛ 8 = 2 * 1 * 1'), isCorrect(2)));
  });

  group('assignment examples', () {
    test('(5-2)! = 6*1', () => expect(check('( 5 - 2 ) ! = 6 * 1'), isCorrect(6)));
    test('unary minus: -(2-5) = 3', () => expect(check('- ( 2 - 5 ) = 3'), isCorrect(3)));
  });

  group('levels', () {
    test('operator sets match the assignment', () {
      expect(Level.easy.operators, containsAll([TokenKind.floorOpen, TokenKind.ceilOpen, TokenKind.cbrt]));
      expect(Level.intermediate.operators,
          containsAll([TokenKind.sqrt, TokenKind.cbrt, TokenKind.factorial, TokenKind.power, TokenKind.absOpen]));
      expect(Level.intermediate.operators, isNot(contains(TokenKind.floorOpen)));
      expect(Level.advanced.operators, containsAll([TokenKind.sqrt, TokenKind.factorial, TokenKind.absOpen]));
      expect(Level.advanced.operators, isNot(contains(TokenKind.cbrt)));
      expect(Level.advanced.operators, isNot(contains(TokenKind.power)));
      expect(Level.hard.operators, {
        TokenKind.plus, TokenKind.minus, TokenKind.times, TokenKind.divide,
        TokenKind.parenOpen, TokenKind.parenClose, TokenKind.absOpen, TokenKind.absClose,
      });
    });

    test('non-integer division allowed only in easy', () {
      expect(check('5 / 2 = 5 / 2', level: Level.easy), isCorrect(2.5));
      for (final level in [Level.intermediate, Level.advanced, Level.hard]) {
        expect(check('5 / 2 = 5 / 2', level: level), isInvalid<NonIntegerDivision>());
      }
    });

    test('integer division is fine in every level', () {
      expect(check('8 / 2 = 4 * 1', level: Level.hard), isCorrect(4));
    });

    test('operator outside the level is rejected', () {
      expect(check('√ 9 = 3 * 1', level: Level.hard), isInvalid<OperatorNotAllowed>());
    });
  });

  group('structure errors', () {
    test('missing =', () => expect(check('2 + 3 * 1 + 1'), isInvalid<MissingEquals>()));
    test('two =', () => expect(check('2 = 2 = 2'), isInvalid<MultipleEquals>()));
    test('= at the start', () => expect(check('= 2 + 2'), isInvalid<EmptySide>()));
    test('= at the end', () => expect(check('2 + 2 ='), isInvalid<EmptySide>()));
    test('digits never concatenate', () => expect(check('2 3 = 2 3'), isInvalid<MissingOperator>()));
    test('implicit multiplication is not allowed', () {
      expect(check('2 ( 3 ) = 6 * 1'), isInvalid<MissingOperator>());
    });
    test('digits must match the puzzle', () {
      expect(check('3 = 3', digits: [3, 4]), isInvalid<DigitsMismatch>());
    });
    test('wrong order of digits', () {
      expect(check('2 + 1 = 3', digits: [1, 2, 3]), isInvalid<DigitsMismatch>());
    });
  });

  group('syntax errors', () {
    test('unclosed group', () => expect(check('( 2 + 2 = 4'), isInvalid<UnclosedGroup>()));
    test('wrong closer', () => expect(check('( 2 + 2 ⌋ = 4'), isInvalid<UnexpectedCloser>()));
    test('stray closer', () => expect(check('2 ) = 2'), isInvalid<UnexpectedCloser>()));
    test('operator after =', () => expect(check('2 = / 2'), isInvalid<MissingOperand>()));
    test('dangling operator', () => expect(check('2 + = 2'), isInvalid<MissingOperand>()));
    test('! first', () => expect(check('! 3 = 6'), isInvalid<MisplacedFactorial>()));
    test('error points at the offending piece', () {
      final v = check('2 = 2 ) ') as Invalid;
      expect(v.error.tokenIndex, 3);
    });
  });

  group('math errors', () {
    test('division by zero', () => expect(check('2 / 0 = 2'), isInvalid<DivisionByZero>()));
    test('negative sqrt', () => expect(check('√ ( 1 - 2 ) = 1'), isInvalid<NegativeSqrt>()));
    test('cube root of negative works', () => expect(check('∛ ( 0 - 8 ) = - 2'), isCorrect(-2)));
    test('factorial of non-integer', () => expect(check('( 5 / 2 ) ! = 1'), isInvalid<InvalidFactorial>()));
    test('factorial too large', () {
      expect(check('( 9 + 9 + 3 ) ! = 1'), isInvalid<FactorialTooLarge>());
    });
    test('0 ** -1 is undefined', () => expect(check('0 ** - 1 = 1'), isInvalid<UndefinedResult>()));
  });

  group('precedence and float handling', () {
    test('* before +', () => expect(check('2 + 3 * 4 = 7 + 7'), isCorrect(14)));
    test('** is right-associative', () => expect(check('2 ** 3 ** 2 = 2 ** 9'), isCorrect(512)));
    test('-2**2 is -(2**2)', () => expect(check('- 2 ** 2 = - 4'), isCorrect(-4)));
    test('√9! is (√9)!', () => expect(check('√ 9 ! = 6'), isCorrect(6)));
    test('floating noise does not break equality', () {
      expect(check('∛ ( 2 * 9 + 9 ) = 3', level: Level.easy), isCorrect(3));
      expect(check('⌊ ∛ ( 2 * 9 + 9 ) ⌋ = 3'), isCorrect(3));
    });
    test('different sides are Incorrect', () {
      expect(check('2 + 2 = 5'), isA<Incorrect>());
    });
  });

  group('latex', () {
    test('assignment example', () {
      expect(equationToLatex(parseEquation(board('√ ( 8 + 1 ) = 3 ** 1'))), r'\sqrt{8 + 1} = 3^{1}');
    });
    test('operators and groups', () {
      expect(
        equationToLatex(parseEquation(board('|< 1 - 4 >| = ⌊ 7 / 2 ⌋ * ∛ 1'))),
        r'\left| 1 - 4 \right| = \left\lfloor 7 \div 2 \right\rfloor \times \sqrt[3]{1}',
      );
    });
    test('factorial base is braced', () {
      expect(equationToLatex(parseEquation(board('3 ! ** 2 = 6'))), r'{3!}^{2} = 6');
    });
    test('incomplete board still renders', () {
      expect(boardToLatex(board('√ ( 8 + = 3 ** 1')), r'\surd ( 8 + = 3^{1}');
      expect(boardToLatex(board('2 3')), '2 3');
      expect(boardToLatex([]), '');
    });
  });
}

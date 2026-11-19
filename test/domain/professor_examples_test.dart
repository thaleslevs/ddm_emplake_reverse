import 'package:emplake/features/game/domain/errors.dart';
import 'package:emplake/features/game/domain/judge.dart';
import 'package:flutter_test/flutter_test.dart';

import 'judge_test.dart' show check, isCorrect;

/// Exemplos do aviso do professor (17/11): expressões compostas e precedência.
void main() {
  group('precedência (corretos segundo o professor)', () {
    test('1+2*3 = 7', () => expect(check('1 + 2 * 3 = 7'), isCorrect(7)));
    test('2*3! = 8+4', () => expect(check('2 * 3 ! = 8 + 4'), isCorrect(12)));
    test('-2+2 = 0+0', () => expect(check('- 2 + 2 = 0 + 0'), isCorrect(0)));
    test('--2+0! = 3+0', () => expect(check('- - 2 + 0 ! = 3 + 0'), isCorrect(3)));
    test('-(-2+5) = 4-7', () => expect(check('- ( - 2 + 5 ) = 4 - 7'), isCorrect(-3)));
  });

  group('expressões compostas são aceitas pela sintaxe', () {
    // O resultado pode não ser igual; o que importa é não dar erro de montagem.
    bool syntaxOk(Verdict v) => switch (v) {
      Invalid(:final error) => error is! MissingOperator &&
          error is! MissingOperand &&
          error is! UnclosedGroup &&
          error is! UnexpectedCloser &&
          error is! MisplacedFactorial,
      _ => true,
    };

    test('--(∛(-(3!-√8)) + 7!!) = ∛(√(8!))', () {
      final v = check('- - ( ∛ ( - ( 3 ! - √ 8 ) ) + 7 ! ! ) = ∛ ( √ ( 8 ! ) )');
      expect(syntaxOk(v), isTrue, reason: '$v');
    });

    test('√(√(-(2-6)!!)!) = (√8)*1!', () {
      final v = check('√ ( √ ( - ( 2 - 6 ) ! ! ) ! ) = ( √ 8 ) * 1 !');
      expect(syntaxOk(v), isTrue, reason: '$v');
    });

    test('√8! + 0 = 1 + 1 agrupa como (√8)!', () {
      final v = check('√ 8 ! + 0 = 1 + 1');
      expect(syntaxOk(v), isTrue, reason: '$v');
    });
  });
}

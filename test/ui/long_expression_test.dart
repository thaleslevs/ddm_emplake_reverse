import 'package:emplake/core/theme/game_palette.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/token.dart';
import 'package:emplake/features/game/state/game_controller.dart';
import 'package:emplake/features/game/ui/drag_support.dart';
import 'package:emplake/features/game/ui/expression_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Expressões compostas (como as do aviso do professor) têm quase 30 peças:
/// no celular o quadro precisa quebrar a linha, sem estourar a tela.
void main() {
  testWidgets('expressão longa quebra em várias linhas num celular', (tester) async {
    tester.view.physicalSize = const Size(375, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final keys = PieceKeys();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(extensions: [GamePalette.forVariant(ThemeVariant.felt)]),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ExpressionBoard(level: Level.easy, keys: keys),
            ),
          ),
        ),
      ),
    );

    final controller = container.read(gameControllerProvider(Level.easy).notifier);
    final singleLine = tester.getSize(find.byType(ExpressionBoard)).height;

    // ( ( ( 4 dígitos ... ) ) ) com 24 operadores: 28 peças no total.
    for (var i = 0; i < 12; i++) {
      controller.insertPiece(TokenKind.parenOpen, 0);
      controller.insertPiece(TokenKind.factorial, container.read(gameControllerProvider(Level.easy)).board.length);
    }
    await tester.pumpAndSettle();

    expect(container.read(gameControllerProvider(Level.easy)).board, hasLength(28));
    expect(tester.takeException(), isNull, reason: 'nada pode estourar a largura');
    final board = tester.getSize(find.byType(ExpressionBoard));
    expect(board.width, lessThanOrEqualTo(375 - 32));
    expect(board.height, greaterThan(singleLine));

    // Conta as linhas pela altura de cada peça; todas dentro da tela.
    final rows = <double>{};
    for (final token in container.read(gameControllerProvider(Level.easy)).board) {
      final rect = tester.getRect(find.byKey(keys.board(token.id)));
      expect(rect.right, lessThanOrEqualTo(375));
      rows.add(rect.top.roundToDouble());
    }
    expect(rows.length, greaterThanOrEqualTo(3), reason: 'deve quebrar em pelo menos 3 linhas');
  });
}

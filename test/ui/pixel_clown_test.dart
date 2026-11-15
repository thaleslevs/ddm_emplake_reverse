import 'package:emplake/core/ui/pixel_clown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final skin in ClownSkins.all) {
    for (final look in ClownLook.values) {
      test('${skin.id}/${look.name}: grade regular e todas as letras com cor', () {
        final rows = PixelClown.shape(look, skin);
        expect(rows, hasLength(22));
        final width = look == ClownLook.thumbsUp ? 20 : 16;
        for (final row in rows) {
          expect(row.length, width, reason: '"$row"');
        }
        for (final colors in [skin.left, skin.right, skin.happy, skin.sad]) {
          for (final row in rows) {
            for (final ch in row.split('')) {
              if (ch == '.') continue;
              expect(colors.of(ch), isNotNull, reason: 'letra "$ch" sem cor em "$row"');
            }
          }
        }
      });
    }
  }

  test('skins mudam o desenho de verdade', () {
    final classic = PixelClown.shape(ClownLook.neutral);
    for (final skin in ClownSkins.all.skip(1)) {
      expect(PixelClown.shape(ClownLook.neutral, skin), isNot(equals(classic)), reason: skin.id);
    }
  });

  test('chorando tem lágrimas em toda skin', () {
    for (final skin in ClownSkins.all) {
      expect(PixelClown.shape(ClownLook.crying, skin).join().contains('r'), isTrue, reason: skin.id);
    }
  });
}

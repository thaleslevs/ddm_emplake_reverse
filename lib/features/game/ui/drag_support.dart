import 'package:flutter/widgets.dart';

import '../domain/token.dart';

sealed class PiecePayload {
  const PiecePayload();
}

final class NewPiece extends PiecePayload {
  const NewPiece(this.kind);
  final TokenKind kind;
}

final class PlacedPiece extends PiecePayload {
  const PlacedPiece(this.token);
  final Token token;
}

class PieceKeys {
  final _board = <String, GlobalKey>{};
  final _palette = <TokenKind, GlobalKey>{};
  final equalsHolder = GlobalKey(debugLabel: 'equals-holder');

  GlobalKey board(String tokenId) => _board.putIfAbsent(tokenId, GlobalKey.new);
  GlobalKey palette(TokenKind kind) => _palette.putIfAbsent(kind, GlobalKey.new);

  GlobalKey home(TokenKind kind) => kind == TokenKind.equals ? equalsHolder : palette(kind);

  void retainBoard(Iterable<String> ids) {
    final keep = ids.toSet();
    _board.removeWhere((id, _) => !keep.contains(id));
  }

  static Rect? rectOf(GlobalKey key, RenderBox ancestor) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: ancestor);
    return topLeft & box.size;
  }
}

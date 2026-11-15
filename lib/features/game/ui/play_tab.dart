import 'package:flutter/material.dart';

import 'game_page.dart';

/// Aba Jogar. Os resolvidos já foram carregados pelo `AccountGate`.
class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context) => const GamePage();
}

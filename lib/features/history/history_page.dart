import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/game_palette.dart';
import '../../core/ui/page_frame.dart';
import '../../l10n/gen/app_localizations.dart';
import '../game/data/solved_repository.dart';
import '../game/state/solved_store.dart';
import '../game/ui/game_texts.dart';

/// Números resolvidos pelo jogador, do mais recente para o mais antigo, com a
/// igualdade que ele montou.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  Future<List<SolvedEntry>>? _future;
  int _loadedFor = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = ref.watch(solvedRepositoryProvider);
    // A aba fica viva no shell: recarrega quando o jogador resolve mais um.
    final solvedCount = ref.watch(solvedProvider.select((s) => s.values.fold(0, (n, set) => n + set.length)));
    if (repository != null && (_future == null || solvedCount != _loadedFor)) {
      _loadedFor = solvedCount;
      _future = repository.history();
    }

    return PageFrame(
      title: l10n.historyTitle,
      children: [
        FutureBuilder<List<SolvedEntry>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(color: GamePalette.of(context).gold, size: 48),
                ),
              );
            }
            if (snapshot.hasError) return _Message(l10n.historyLoadError);
            final entries = snapshot.data ?? const [];
            if (entries.isEmpty) return _Message(l10n.historyEmpty);
            return Column(
              children: [
                for (final entry in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EntryTile(entry: entry),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final SolvedEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final when = entry.solvedAt == null ? null : DateFormat.yMd(locale).add_Hm().format(entry.solvedAt!);
    return GamePanel(
      child: Row(
        children: [
          Text(entry.number, style: GameType.display(36, p.gold)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(entry.latex, textStyle: text.titleMedium!.copyWith(color: p.text)),
                ),
                const SizedBox(height: 4),
                Text(
                  when == null ? l10n.levelName(entry.level) : '${l10n.levelName(entry.level)} · $when',
                  style: text.bodySmall!.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return GamePanel(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: GamePalette.of(context).textMuted),
      ),
    );
  }
}

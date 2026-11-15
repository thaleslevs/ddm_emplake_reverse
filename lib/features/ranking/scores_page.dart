import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/game_palette.dart';
import '../../core/ui/page_frame.dart';
import '../../l10n/gen/app_localizations.dart';
import '../game/state/solved_store.dart';
import '../history/history_page.dart';
import '../shop/account.dart';
import '../shop/shop_actions.dart';
import 'leaderboard_repository.dart';

/// Aba Placar: resumo dos pontos e duas vistas, o ranking geral (pelo total
/// de pontos já ganhos) e os números que o jogador resolveu.
class ScoresPage extends ConsumerStatefulWidget {
  const ScoresPage({super.key});

  @override
  ConsumerState<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends ConsumerState<ScoresPage> {
  bool _showRanking = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final text = Theme.of(context).textTheme;
    return PageFrame(
      title: l10n.scoresTitle,
      children: [
        GamePanel(
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: p.gold, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.earnedLabel(ref.watch(scoreProvider)), style: GameType.display(28, p.gold)),
                    Text(
                      '${l10n.balanceLabel(ref.watch(balanceProvider))} · '
                      '${l10n.historySolvedCount(ref.watch(solvedCountProvider))}',
                      style: text.bodyMedium!.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final (ranking, icon, label) in [
              (true, Icons.emoji_events_rounded, l10n.scoresRanking),
              (false, Icons.history_rounded, l10n.scoresMine),
            ])
              ChoiceChip(
                avatar: Icon(icon, size: 18, color: _showRanking == ranking ? p.gold : p.textMuted),
                label: Text(label),
                selected: _showRanking == ranking,
                showCheckmark: false,
                labelStyle: TextStyle(color: p.text),
                backgroundColor: p.panelRaised,
                selectedColor: p.gold.withValues(alpha: 0.25),
                side: BorderSide(color: _showRanking == ranking ? p.gold : p.border),
                onSelected: (_) => setState(() => _showRanking = ranking),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_showRanking) const _RankingView() else const HistoryList(),
      ],
    );
  }
}

class _RankingView extends ConsumerStatefulWidget {
  const _RankingView();

  @override
  ConsumerState<_RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends ConsumerState<_RankingView> {
  Future<(List<LeaderboardEntry>, int)>? _future;
  (int, String)? _loadedFor;

  Future<(List<LeaderboardEntry>, int)> _load(LeaderboardRepository repo, int points) async {
    final (top, position) = await (repo.top(), repo.positionOf(points)).wait;
    return (top, position);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final text = Theme.of(context).textTheme;
    final repo = ref.watch(leaderboardRepositoryProvider);
    final points = ref.watch(scoreProvider);
    final nickname = ref.watch(accountProvider.select((a) => a.nickname));
    // Recarrega quando os pontos ou o apelido mudam.
    if (repo != null && (_future == null || _loadedFor != (points, nickname))) {
      _loadedFor = (points, nickname);
      _future = _load(repo, points);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GamePanel(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.badge_rounded, color: p.textMuted, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.rankingNickname(nickname),
                  style: text.bodyMedium!.copyWith(color: p.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () => _editNickname(context, nickname),
                icon: Icon(Icons.edit_rounded, size: 18, color: p.gold),
                label: Text(l10n.rankingEditNickname, style: TextStyle(color: p.gold)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(l10n.rankingNote, style: text.bodySmall!.copyWith(color: p.textMuted)),
        ),
        FutureBuilder<(List<LeaderboardEntry>, int)>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: LoadingAnimationWidget.staggeredDotsWave(color: p.gold, size: 48)),
              );
            }
            if (snapshot.hasError || snapshot.data == null) return _Message(l10n.rankingLoadError);
            final (entries, position) = snapshot.data!;
            if (entries.isEmpty) return _Message(l10n.rankingEmpty);
            final me = repo?.uid;
            final inTop = entries.any((e) => e.uid == me);
            return Column(
              children: [
                for (final (i, entry) in entries.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RankRow(position: i + 1, entry: entry, isMe: entry.uid == me),
                  ),
                if (!inTop && me != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _RankRow(
                      position: position,
                      entry: LeaderboardEntry(uid: me, name: nickname, points: points),
                      isMe: true,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _editNickname(BuildContext context, String current) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.nicknameDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: InputDecoration(hintText: l10n.nicknameHint),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: Text(l10n.save)),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) await ref.read(shopActionsProvider).rename(name);
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.position, required this.entry, required this.isMe});

  final int position;
  final LeaderboardEntry entry;
  final bool isMe;

  /// Ouro, prata e bronze para os três primeiros.
  static const _medals = [Color(0xFFF2C744), Color(0xFFC9D1DA), Color(0xFFCD8A4E)];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final medal = position <= 3 ? _medals[position - 1] : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? p.gold.withValues(alpha: 0.18) : p.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isMe ? p.gold : p.border, width: isMe ? 2 : 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: medal != null
                ? Icon(Icons.emoji_events_rounded, color: medal, size: 28)
                : Text(l10n.rankingPosition(position), style: GameType.display(24, p.textMuted)),
          ),
          Expanded(
            child: Text(
              isMe ? '${entry.name} (${l10n.rankingYou})' : entry.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: p.text, fontWeight: FontWeight.w600),
            ),
          ),
          Text('${entry.points}', style: GameType.display(26, p.gold)),
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

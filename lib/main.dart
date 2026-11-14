import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/game/ui/game_page.dart';
import 'l10n/gen/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: EmplakeApp()));
}

class EmplakeApp extends ConsumerWidget {
  const EmplakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = buildGameTheme(ref.watch(themeVariantProvider));
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const GamePage(),
    );
  }
}

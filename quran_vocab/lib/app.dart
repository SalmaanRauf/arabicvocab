import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/routes/app_router.dart';
import 'presentation/state/settings_providers.dart';
import 'presentation/theme/app_theme.dart';

class QuranVocabApp extends ConsumerWidget {
  const QuranVocabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = AppRouter.router;
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Quranic Vocabulary',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

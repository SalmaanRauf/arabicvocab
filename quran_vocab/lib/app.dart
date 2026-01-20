import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/routes/app_router.dart';
import 'presentation/theme/app_theme.dart';

class QuranVocabApp extends StatelessWidget {
  const QuranVocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppRouter.router;
    return MaterialApp.router(
      title: 'Quranic Vocabulary',
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

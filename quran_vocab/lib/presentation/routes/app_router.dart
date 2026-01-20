import 'package:go_router/go_router.dart';

import '../views/home_view.dart';
import '../views/reader_view.dart';
import '../views/review_view.dart';
import '../views/settings_view.dart';

class AppRouter {
  static const String homePath = '/';
  static const String readerPath = '/reader';
  static const String reviewPath = '/review';
  static const String settingsPath = '/settings';

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: readerPath,
        builder: (context, state) => const ReaderView(),
      ),
      GoRoute(
        path: reviewPath,
        builder: (context, state) => const ReviewView(),
      ),
      GoRoute(
        path: settingsPath,
        builder: (context, state) => const SettingsView(),
      ),
    ],
  );
}

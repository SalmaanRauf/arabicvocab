import 'package:go_router/go_router.dart';

import '../views/curriculum_view.dart';
import '../views/daily_lesson_view.dart';
import '../views/dashboard_view.dart';
import '../views/home_view.dart';
import '../views/lesson_detail_view.dart';
import '../views/quran_hub_view.dart';
import '../views/reader_view.dart';
import '../views/review_view.dart';
import '../views/settings_view.dart';
import '../widgets/app_shell.dart';

class AppRouter {
  static const String homePath = '/';
  static const String quranPath = '/quran';
  static const String readerPath = '/reader';
  static const String reviewPath = '/review';
  static const String settingsPath = '/settings';
  static const String curriculumPath = '/curriculum';
  static const String lessonPath = '/lesson';
  static const String progressPath = '/progress';
  static const String dailyLessonPath = '/daily';

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: homePath,
                builder: (context, state) => const HomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: quranPath,
                builder: (context, state) => const QuranHubView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dailyLessonPath,
                builder: (context, state) => const DailyLessonView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: reviewPath,
                builder: (context, state) => const ReviewView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: progressPath,
                builder: (context, state) => const DashboardView(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: readerPath,
        builder: (context, state) => const ReaderView(),
      ),
      GoRoute(
        path: settingsPath,
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: curriculumPath,
        builder: (context, state) => const CurriculumView(),
      ),
      GoRoute(
        path: lessonPath,
        builder: (context, state) => const LessonDetailView(),
      ),
    ],
  );
}

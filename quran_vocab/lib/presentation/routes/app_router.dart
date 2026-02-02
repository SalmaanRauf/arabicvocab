import 'package:go_router/go_router.dart';

import '../views/curriculum_view.dart';
import '../views/dashboard_view.dart';
import '../views/home_view.dart';
import '../views/lesson_detail_view.dart';
import '../views/reader_view.dart';
import '../views/review_view.dart';
import '../views/settings_view.dart';

class AppRouter {
  static const String homePath = '/';
  static const String readerPath = '/reader';
  static const String reviewPath = '/review';
  static const String settingsPath = '/settings';
  static const String curriculumPath = '/curriculum';
  static const String lessonPath = '/lesson';
  static const String dashboardPath = '/dashboard';

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
      GoRoute(
        path: curriculumPath,
        builder: (context, state) => const CurriculumView(),
      ),
      GoRoute(
        path: lessonPath,
        builder: (context, state) => const LessonDetailView(),
      ),
      GoRoute(
        path: dashboardPath,
        builder: (context, state) => const DashboardView(),
      ),
    ],
  );
}



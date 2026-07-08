import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/state/app_state.dart';
import '../features/badges/badges_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/live/celebration_screen.dart';
import '../features/live/closure_screen.dart';
import '../features/live/live_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/situations/situation_picker_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final hasProfile = ref.read(profileProvider) != null;
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!hasProfile && !goingToOnboarding) return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          editing: state.uri.queryParameters['edit'] == '1',
        ),
      ),
      GoRoute(
        path: '/situations',
        builder: (context, state) => const SituationPickerScreen(),
      ),
      GoRoute(
        path: '/live/:id',
        builder: (context, state) =>
            LiveScreen(situationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/closure',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return ClosureScreen(
            situationId: extra['situation'] as String? ?? '',
            stepsCompleted: extra['steps'] as int? ?? 0,
            intervened: extra['intervened'] as bool? ?? false,
            level: extra['level'] as int? ?? 1,
            variantsShown: (extra['variants'] as List<dynamic>?)?.cast<int>(),
          );
        },
      ),
      GoRoute(
        path: '/celebration',
        builder: (context, state) => const CelebrationScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/badges',
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

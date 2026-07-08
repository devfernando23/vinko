import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'core/services/reminder_service.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/coach/coach_providers.dart';
import 'features/coach/coach_repository.dart';
import 'features/situations/situations_data.dart';
import 'features/situations/situations_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final situations = await SituationsRepository.load();
  final coach = await CoachRepository.load();
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        situationsProvider.overrideWithValue(situations),
        coachProvider.overrideWithValue(coach),
      ],
      child: const VinkoApp(),
    ),
  );
}

class VinkoApp extends ConsumerStatefulWidget {
  const VinkoApp({super.key});

  @override
  ConsumerState<VinkoApp> createState() => _VinkoAppState();
}

class _VinkoAppState extends ConsumerState<VinkoApp> {
  @override
  void initState() {
    super.initState();
    // Reprograma el aviso diario con la misión vigente: el texto rota
    // con la semana y con el nivel, así que se refresca en cada arranque.
    if (ref.read(settingsProvider).reminders) {
      ReminderService.instance
          .scheduleDaily(body: ref.read(reminderBodyProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final largeText = ref.watch(settingsProvider).largeText;

    return MaterialApp.router(
      title: 'Vinko',
      debugShowCheckedModeBanner: false,
      theme: VinkoTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        // Accesibilidad: escala de texto ampliada desde Ajustes.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: largeText
                ? const TextScaler.linear(1.2)
                : media.textScaler,
          ),
          child: child!,
        );
      },
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vinko/core/models/coach_content.dart';
import 'package:vinko/core/models/situation.dart';
import 'package:vinko/core/state/app_state.dart';
import 'package:vinko/features/coach/coach_providers.dart';
import 'package:vinko/features/coach/coach_repository.dart';
import 'package:vinko/features/situations/situations_data.dart';
import 'package:vinko/features/situations/situations_repository.dart';
import 'package:vinko/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Situation> situations;
  late CoachContent coach;

  setUpAll(() async {
    situations = await SituationsRepository.load();
    coach = await CoachRepository.load();
  });

  Widget app(SharedPreferences prefs) => ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          situationsProvider.overrideWithValue(situations),
          coachProvider.overrideWithValue(coach),
        ],
        child: const VinkoApp(),
      );

  testWidgets('sin perfil, arranca en onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(app(prefs));
    await tester.pumpAndSettle();

    expect(find.text('Soy Vinko.'), findsOneWidget);
  });

  testWidgets('con perfil, arranca en inicio', (tester) async {
    SharedPreferences.setMockInitialValues({
      'child_profile': '{"name":"Mia","age":5,"challenges":["greet"]}',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(app(prefs));
    // El inicio tiene la animación de respiración (loop infinito):
    // pumpAndSettle nunca terminaría, se avanza con pumps fijos.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Necesito ayuda ahora'), findsOneWidget);
    expect(find.text('Qué hacer, justo en el momento'), findsOneWidget);
  });
}

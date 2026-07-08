import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child_profile.dart';
import '../models/session_record.dart';

/// Se sobreescribe en main() con la instancia real, ya cargada.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override en main()'),
);

// ---------------------------------------------------------------------------
// Perfil del niño
// ---------------------------------------------------------------------------

class ProfileNotifier extends Notifier<ChildProfile?> {
  static const _key = 'child_profile';

  @override
  ChildProfile? build() =>
      ChildProfile.fromJson(ref.read(sharedPrefsProvider).getString(_key));

  Future<void> save(ChildProfile profile) async {
    state = profile;
    await ref.read(sharedPrefsProvider).setString(_key, profile.toJson());
  }

  /// "Cerrar sesión" / cambiar de hijo: borra todo y vuelve al onboarding.
  Future<void> clearAll() async {
    await ref.read(sharedPrefsProvider).clear();
    state = null;
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, ChildProfile?>(ProfileNotifier.new);

// ---------------------------------------------------------------------------
// Historial de sesiones: la fuente de verdad del progreso
// ---------------------------------------------------------------------------

class SessionHistoryNotifier extends Notifier<List<SessionRecord>> {
  static const _key = 'session_history';
  static const _maxEntries = 300;

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  List<SessionRecord> build() =>
      SessionRecord.listFromJson(_prefs.getString(_key));

  /// Registra una sesión cerrada (desde la pantalla de cierre).
  Future<void> add(SessionRecord record) async {
    final next = [...state, record];
    if (next.length > _maxEntries) {
      next.removeRange(0, next.length - _maxEntries);
    }
    state = next;
    await _prefs.setString(_key, SessionRecord.listToJson(next));
  }
}

final sessionHistoryProvider =
    NotifierProvider<SessionHistoryNotifier, List<SessionRecord>>(
        SessionHistoryNotifier.new);

// ---------------------------------------------------------------------------
// Progreso: derivado del historial (racha, pasos, semana)
// ---------------------------------------------------------------------------

class ProgressData {
  const ProgressData({
    required this.streakDays,
    required this.stepsDone,
    required this.situationsToday,
    required this.weekSteps,
  });

  final int streakDays;
  final int stepsDone;
  final int situationsToday;

  /// Pasos logrados por día de la semana actual, lunes a domingo.
  final List<int> weekSteps;

  /// Deriva todo el progreso del historial. Pura para poder testearla.
  factory ProgressData.fromHistory(List<SessionRecord> history, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final activeDays = <DateTime>{};
    var stepsDone = 0;
    var situationsToday = 0;
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weekSteps = List<int>.filled(7, 0);

    for (final r in history) {
      final day = DateTime(r.at.year, r.at.month, r.at.day);
      activeDays.add(day);
      stepsDone += r.stepsCompleted;
      if (day == today) situationsToday++;
      final weekIndex = day.difference(monday).inDays;
      if (weekIndex >= 0 && weekIndex < 7) {
        weekSteps[weekIndex] += r.stepsCompleted;
      }
    }

    // Racha: días consecutivos con actividad. Si hoy todavía no hubo,
    // se cuenta desde ayer; si ayer tampoco, la racha es 0.
    var cursor = activeDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (activeDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return ProgressData(
      streakDays: streak,
      stepsDone: stepsDone,
      situationsToday: situationsToday,
      weekSteps: weekSteps,
    );
  }
}

final progressProvider = Provider<ProgressData>((ref) {
  final history = ref.watch(sessionHistoryProvider);
  return ProgressData.fromHistory(history, DateTime.now());
});

// ---------------------------------------------------------------------------
// Recompensas: cómo se celebra (neutral, sin marca)
// ---------------------------------------------------------------------------

class RewardSettings {
  const RewardSettings({
    required this.celebrationScreen,
    required this.softSound,
    required this.stars,
    required this.vinkoMessage,
  });

  final bool celebrationScreen;
  final bool softSound;
  final bool stars;
  final bool vinkoMessage;

  RewardSettings copyWith({
    bool? celebrationScreen,
    bool? softSound,
    bool? stars,
    bool? vinkoMessage,
  }) =>
      RewardSettings(
        celebrationScreen: celebrationScreen ?? this.celebrationScreen,
        softSound: softSound ?? this.softSound,
        stars: stars ?? this.stars,
        vinkoMessage: vinkoMessage ?? this.vinkoMessage,
      );
}

class RewardsNotifier extends Notifier<RewardSettings> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  RewardSettings build() => RewardSettings(
        celebrationScreen: _prefs.getBool('rw_celebration') ?? true,
        softSound: _prefs.getBool('rw_sound') ?? false,
        stars: _prefs.getBool('rw_stars') ?? true,
        vinkoMessage: _prefs.getBool('rw_message') ?? true,
      );

  Future<void> update(RewardSettings next) async {
    state = next;
    await _prefs.setBool('rw_celebration', next.celebrationScreen);
    await _prefs.setBool('rw_sound', next.softSound);
    await _prefs.setBool('rw_stars', next.stars);
    await _prefs.setBool('rw_message', next.vinkoMessage);
  }
}

final rewardsProvider =
    NotifierProvider<RewardsNotifier, RewardSettings>(RewardsNotifier.new);

// ---------------------------------------------------------------------------
// Ajustes generales
// ---------------------------------------------------------------------------

class AppSettings {
  const AppSettings({required this.reminders, required this.largeText});

  final bool reminders;
  final bool largeText;

  AppSettings copyWith({bool? reminders, bool? largeText}) => AppSettings(
        reminders: reminders ?? this.reminders,
        largeText: largeText ?? this.largeText,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  AppSettings build() => AppSettings(
        reminders: _prefs.getBool('set_reminders') ?? false,
        largeText: _prefs.getBool('set_large_text') ?? false,
      );

  Future<void> update(AppSettings next) async {
    state = next;
    await _prefs.setBool('set_reminders', next.reminders);
    await _prefs.setBool('set_large_text', next.largeText);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

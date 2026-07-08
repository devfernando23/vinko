import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/session_record.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/vinko_card.dart';
import '../coach/coach_providers.dart';
import '../situations/situations_data.dart';

const _weekLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  /// Refuerzo concreto a partir de la última sesión registrada.
  String _reinforcement(SessionRecord last, String name, String title) {
    final today = DateTime.now();
    final sameDay = last.at.year == today.year &&
        last.at.month == today.month &&
        last.at.day == today.day;
    final when = sameDay ? 'Hoy' : 'La última vez';
    if (last.intervened) {
      return '$when interviniste en "$title". Estar ahí también es guiar.';
    }
    return switch (last.result) {
      SessionResult.success =>
        '$when $name lo logró: "$title". Paso a paso, con su propio ritmo.',
      SessionResult.soso =>
        '$when $name lo intentó: "$title". Intentarlo ya es avanzar.',
      SessionResult.hard =>
        '$when costó: "$title". Está bien. La próxima, la vara va más abajo.',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final progress = ref.watch(progressProvider);
    final history = ref.watch(sessionHistoryProvider);
    final name = ref.watch(profileProvider)?.name ?? 'tu hijo';
    final maxWeek = max(progress.weekSteps.reduce(max), 1);
    final mission = ref.watch(missionProvider);
    final tip = ref.watch(dailyTipProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progreso')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: PhosphorIconsFill.flame,
                    value: '${progress.streakDays}',
                    label: 'días seguidos',
                    color: VinkoColors.adjust,
                  ),
                ),
                const SizedBox(width: VinkoSpacing.gap),
                Expanded(
                  child: _StatCard(
                    icon: PhosphorIconsFill.footprints,
                    value: '${progress.stepsDone}',
                    label: 'pasos logrados',
                    color: VinkoColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: VinkoSpacing.gap),
            // Refuerzo de Vinko: concreto, desde la última sesión real.
            VinkoCard(
              color: VinkoColors.actionSoft,
              borderColor: VinkoColors.action,
              child: Row(
                children: [
                  const PhosphorIcon(PhosphorIconsFill.compass,
                      size: 28, color: VinkoColors.action),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            history.isEmpty
                                ? 'Vinko te espera'
                                : 'Vinko vio esto',
                            style: theme.labelLarge
                                ?.copyWith(color: VinkoColors.action)),
                        const SizedBox(height: 4),
                        Text(
                          history.isEmpty
                              ? 'Cuando pase algo, toca "Necesito ayuda '
                                  'ahora". Lo que $name logre queda acá.'
                              : _reinforcement(
                                  history.last,
                                  name,
                                  situationById(
                                    ref.watch(situationsProvider),
                                    history.last.situationId,
                                  ).title.toLowerCase(),
                                ),
                          style: theme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Esta semana', style: theme.titleMedium),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < progress.weekSteps.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(
                            child: _WeekBar(
                              value: progress.weekSteps[i],
                              max: maxWeek,
                              label: _weekLabels[i],
                              highlight: i == DateTime.now().weekday - 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Entre crisis: práctica de la semana y tip del día.
            if (mission != null) ...[
              const SizedBox(height: VinkoSpacing.gap),
              _CoachCard(
                icon: PhosphorIconsFill.gameController,
                title: 'Práctica en casa · ${mission.situationTitle}',
                text: mission.practice,
                color: VinkoColors.success,
              ),
            ],
            if (tip.isNotEmpty) ...[
              const SizedBox(height: VinkoSpacing.gap),
              _CoachCard(
                icon: PhosphorIconsFill.lightbulb,
                title: 'Tip del día',
                text: tip,
                color: VinkoColors.adjust,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final PhosphorIconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return VinkoCard(
      child: Row(
        children: [
          PhosphorIcon(icon, size: 28, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.labelLarge?.copyWith(color: color)),
                const SizedBox(height: 4),
                Text(text,
                    style:
                        theme.bodyMedium?.copyWith(color: VinkoColors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final PhosphorIconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return VinkoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(icon, size: 26, color: color),
          const SizedBox(height: 10),
          Text(value,
              style: theme.headlineMedium?.copyWith(fontSize: 30)),
          Text(label, style: theme.bodyMedium),
        ],
      ),
    );
  }
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({
    required this.value,
    required this.max,
    required this.label,
    required this.highlight,
  });

  final int value;
  final int max;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final fraction = max == 0 ? 0.0 : value / max;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction.clamp(0.06, 1.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: highlight
                      ? VinkoColors.action
                      : (value > 0
                          ? VinkoColors.action.withValues(alpha: 0.35)
                          : VinkoColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: theme.labelMedium?.copyWith(
              color: highlight ? VinkoColors.action : VinkoColors.textSecondary,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            )),
      ],
    );
  }
}

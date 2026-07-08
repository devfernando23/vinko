import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/session_record.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/vinko_list_row.dart';
import '../situations/situations_data.dart';

const _months = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun', //
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Últimas situaciones jugadas: para que el padre vea el recorrido y qué
/// funcionó, sin tener que recordarlo de memoria.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _dateLabel(DateTime at, DateTime now) {
    final day = DateTime(at.year, at.month, at.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return '${at.day} de ${_months[at.month - 1]}';
  }

  (String, Color) _resultInfo(SessionRecord r) {
    if (r.intervened) return ('Interviniste', VinkoColors.textSecondary);
    return switch (r.result) {
      SessionResult.success => ('Lo logró', VinkoColors.success),
      SessionResult.soso => ('Más o menos', VinkoColors.action),
      SessionResult.hard => ('Costó', VinkoColors.adjust),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final history = ref.watch(sessionHistoryProvider);
    final situations = ref.watch(situationsProvider);
    final now = DateTime.now();
    final entries = history.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: SafeArea(
        child: entries.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
                child: Center(
                  child: Text(
                    'Todavía no hay situaciones registradas. Cuando cierres '
                    'una, va a aparecer acá.',
                    textAlign: TextAlign.center,
                    style: theme.bodyLarge
                        ?.copyWith(color: VinkoColors.textSecondary),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
                itemCount: entries.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: VinkoSpacing.gap),
                itemBuilder: (context, i) {
                  final record = entries[i];
                  final situation =
                      situationById(situations, record.situationId);
                  final (resultLabel, color) = _resultInfo(record);
                  return VinkoListRow(
                    icon: situation.icon,
                    iconColor: color,
                    iconBackground: color.withValues(alpha: 0.14),
                    title: situation.title,
                    subtitle:
                        '${_dateLabel(record.at, now)} · $resultLabel · '
                        '${record.stepsCompleted} pasos',
                    trailing: const SizedBox.shrink(),
                  );
                },
              ),
      ),
    );
  }
}

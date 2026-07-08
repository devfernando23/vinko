import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/services/reminder_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/vinko_list_row.dart';
import '../coach/coach_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _toggleReminders(
      BuildContext context, WidgetRef ref, bool enable) async {
    final notifier = ref.read(settingsProvider.notifier);
    final settings = ref.read(settingsProvider);

    if (!enable) {
      await notifier.update(settings.copyWith(reminders: false));
      await ReminderService.instance.cancel();
      return;
    }

    final ok = await ReminderService.instance
        .scheduleDaily(body: ref.read(reminderBodyProvider));
    if (ok) {
      await notifier.update(settings.copyWith(reminders: true));
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ReminderService.instance.isSupported
              ? 'Vinko no tiene permiso para enviar avisos. '
                  'Actívalo en los ajustes del sistema.'
              : 'Los recordatorios no están disponibles en esta plataforma.'),
        ),
      );
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref,
      {required String title, required String message}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VinkoColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VinkoSpacing.radius)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, continuar',
                style: TextStyle(color: VinkoColors.adjust)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ReminderService.instance.cancel();
      await ref.read(profileProvider.notifier).clearAll();
      if (context.mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
          children: [
            VinkoListRow(
              icon: PhosphorIconsFill.userCircle,
              title: profile?.name ?? 'Perfil del niño',
              subtitle: profile != null
                  ? '${profile.age} años · toca para editar'
                  : 'Completa el onboarding',
              onTap: () => context.push('/onboarding?edit=1'),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.usersThree,
              title: 'Cambiar de hijo',
              subtitle: 'Crea un perfil nuevo',
              onTap: () => _confirmReset(
                context,
                ref,
                title: '¿Cambiar de hijo?',
                message:
                    'Se creará un perfil nuevo. El progreso actual se reinicia.',
              ),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.confetti,
              title: 'Recompensas',
              subtitle: 'Cómo se celebra cuando lo logra',
              onTap: () => context.push('/rewards'),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.bellRinging,
              title: 'Recordatorios',
              subtitle: 'Un aviso por día, a las 7 p. m.',
              trailing: Switch(
                value: settings.reminders,
                onChanged: (v) => _toggleReminders(context, ref, v),
              ),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.textAa,
              title: 'Texto grande',
              subtitle: 'Accesibilidad',
              trailing: Switch(
                value: settings.largeText,
                onChanged: (v) =>
                    notifier.update(settings.copyWith(largeText: v)),
              ),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.question,
              title: 'Ayuda',
              subtitle: 'Cómo usar Vinko en el momento',
              onTap: () => showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: VinkoColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(VinkoSpacing.radius)),
                  title: const Text('Cómo usar Vinko'),
                  content: const Text(
                    'Cuando pase algo, toca "Necesito ayuda ahora". '
                    'Elige la situación y sigue una instrucción a la vez. '
                    'Vinko no reemplaza tu criterio: si hace falta, interviene.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Entendido',
                          style: TextStyle(color: VinkoColors.action)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.signOut,
              title: 'Cerrar sesión',
              subtitle: 'Borra los datos de este dispositivo',
              iconColor: VinkoColors.adjust,
              iconBackground: VinkoColors.adjustSoft,
              onTap: () => _confirmReset(
                context,
                ref,
                title: '¿Cerrar sesión?',
                message: 'Se borran el perfil y el progreso guardados acá.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

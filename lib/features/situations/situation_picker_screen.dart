import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/vinko_card.dart';
import 'situation_level.dart';
import 'situations_data.dart';

class SituationPickerScreen extends ConsumerWidget {
  const SituationPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final all = ref.watch(situationsProvider);
    final challenges =
        ref.watch(profileProvider)?.challenges ?? const <String>[];
    // Primero lo que más le cuesta (elegido en onboarding); 'other' al final.
    final situations = [
      ...all.where((s) => s.id != 'other' && challenges.contains(s.id)),
      ...all.where((s) => s.id != 'other' && !challenges.contains(s.id)),
      ...all.where((s) => s.id == 'other'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('¿Qué está pasando?')),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: VinkoSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vinko te guía paso a paso.', style: theme.bodyMedium),
              const SizedBox(height: VinkoSpacing.gap),
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.only(bottom: VinkoSpacing.screenPadding),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: VinkoSpacing.gap,
                    crossAxisSpacing: VinkoSpacing.gap,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: situations.length,
                  itemBuilder: (context, i) {
                    final s = situations[i];
                    final level = ref.watch(situationLevelProvider(s.id));
                    return VinkoCard(
                      onTap: () => context.push('/live/${s.id}'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: VinkoColors.actionSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: PhosphorIcon(
                                s.icon,
                                size: 28,
                                color: VinkoColors.action,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: theme.titleMedium?.copyWith(fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (s.levels.length > 1) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Nivel $level · ${s.levels[level - 1].label}',
                              textAlign: TextAlign.center,
                              style: theme.labelMedium?.copyWith(
                                color: VinkoColors.action,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

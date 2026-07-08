import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/vinko_badge.dart';
import 'badges_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final name = ref.watch(profileProvider)?.name ?? 'tu hijo';
    final badges = ref.watch(badgesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Insignias')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
          itemCount: badges.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: VinkoSpacing.gap),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Quién se está volviendo $name, paso a paso. '
                  'Cada "lo logró" suma.',
                  style: theme.bodyMedium,
                ),
              );
            }
            return VinkoBadgeCard(badge: badges[i - 1]);
          },
        ),
      ),
    );
  }
}

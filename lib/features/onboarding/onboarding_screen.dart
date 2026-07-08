import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/child_profile.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/vinko_button.dart';
import '../situations/situations_data.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.editing = false});

  /// true cuando se entra desde Ajustes para editar el perfil existente.
  final bool editing;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final TextEditingController _nameController;
  int _age = 5;
  late final Set<String> _challenges;

  @override
  void initState() {
    super.initState();
    final existing = widget.editing ? ref.read(profileProvider) : null;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _age = existing?.age ?? 5;
    _challenges = {...?existing?.challenges};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await ref.read(profileProvider.notifier).save(
          ChildProfile(
            name: name,
            age: _age,
            challenges: _challenges.toList(),
          ),
        );
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    // "Otra" no es un desafío elegible en onboarding.
    final options =
        ref.watch(situationsProvider).where((s) => s.id != 'other');

    return Scaffold(
      appBar: widget.editing
          ? AppBar(title: const Text('Perfil del niño'))
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
          children: [
            if (!widget.editing) ...[
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: VinkoColors.action,
                  shape: BoxShape.circle,
                  boxShadow: vinkoSoftShadow(opacity: 0.15),
                ),
                child: const Center(
                  child: PhosphorIcon(PhosphorIconsFill.compass,
                      size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text('Soy Vinko.', style: theme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Te digo qué hacer, justo en el momento. Primero, cuéntame de tu hijo.',
                style: theme.bodyLarge
                    ?.copyWith(color: VinkoColors.textSecondary),
              ),
              const SizedBox(height: 32),
            ],
            Text('¿Cómo se llama?', style: theme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Nombre'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 28),
            Text('¿Cuántos años tiene?', style: theme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var age = 3; age <= 10; age++)
                  ChoiceChip(
                    label: Text('$age'),
                    selected: _age == age,
                    onSelected: (_) => setState(() => _age = age),
                    selectedColor: VinkoColors.action,
                    backgroundColor: VinkoColors.surface,
                    labelStyle: TextStyle(
                      color: _age == age ? Colors.white : VinkoColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _age == age
                            ? VinkoColors.action
                            : VinkoColors.border,
                      ),
                    ),
                    showCheckmark: false,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Text('¿Qué le cuesta más?', style: theme.titleMedium),
            const SizedBox(height: 4),
            Text('Puedes elegir varias.', style: theme.bodyMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in options)
                  FilterChip(
                    label: Text(s.title),
                    selected: _challenges.contains(s.id),
                    onSelected: (v) => setState(() {
                      v ? _challenges.add(s.id) : _challenges.remove(s.id);
                    }),
                    selectedColor: VinkoColors.actionSoft,
                    backgroundColor: VinkoColors.surface,
                    checkmarkColor: VinkoColors.action,
                    labelStyle: TextStyle(
                      color: _challenges.contains(s.id)
                          ? VinkoColors.action
                          : VinkoColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _challenges.contains(s.id)
                            ? VinkoColors.action
                            : VinkoColors.border,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            VinkoPrimaryButton(
              label: widget.editing ? 'Guardar' : 'Empezar',
              onPressed:
                  _nameController.text.trim().isEmpty ? null : _save,
            ),
            const SizedBox(height: VinkoSpacing.screenPadding),
          ],
        ),
      ),
    );
  }
}

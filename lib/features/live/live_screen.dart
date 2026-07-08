import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/breathing.dart';
import '../../core/widgets/vinko_button.dart';
import '../../core/widgets/vinko_card.dart';
import '../situations/situation_level.dart';
import '../situations/situations_data.dart';

/// Modo en vivo: una instrucción a la vez, entendible en menos de 2 segundos.
///
/// El nivel de exposición se deriva del historial (situation_level.dart) y
/// fija qué guion se usa. Dentro del nivel, cada paso tiene un banco de
/// variantes: al entrar se sortea una por paso, evitando repetir la de la
/// sesión anterior (se recuerda en prefs). "No funcionó" recorre la cadena
/// de fallbacks del paso.
class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key, required this.situationId});

  final String situationId;

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  int _step = 0;
  int _fallback = -1; // -1: variante principal; >=0: índice en fallbacks

  /// Nivel de exposición con el que se juega esta sesión (1..N).
  late final int _level;

  /// Variante sorteada para cada paso de esta sesión.
  late final List<int> _variantOfStep;

  @override
  void initState() {
    super.initState();
    final situation =
        situationById(ref.read(situationsProvider), widget.situationId);
    _level = ref.read(situationLevelProvider(widget.situationId));
    final steps = situation.levels[_level - 1].steps;
    final prefs = ref.read(sharedPrefsProvider);
    final key = 'variant_last_${widget.situationId}_l$_level';
    final last = prefs.getStringList(key);
    final rng = Random();
    _variantOfStep = [
      for (var i = 0; i < steps.length; i++)
        _pickVariant(
          rng,
          steps[i].variants.length,
          avoid: (last != null && i < last.length)
              ? int.tryParse(last[i])
              : null,
        ),
    ];
    prefs.setStringList(key, [for (final v in _variantOfStep) '$v']);
  }

  /// Índice al azar en [0, poolSize), evitando [avoid] si el pool lo permite.
  int _pickVariant(Random rng, int poolSize, {int? avoid}) {
    if (poolSize <= 1) return 0;
    if (avoid == null || avoid < 0 || avoid >= poolSize) {
      return rng.nextInt(poolSize);
    }
    final i = rng.nextInt(poolSize - 1);
    return i >= avoid ? i + 1 : i;
  }

  void _finish({required int stepsCompleted, required bool intervened}) {
    // Si se intervino, el paso actual se mostró pero no se completó: su
    // variante también cuenta como "vista". Si se terminó, ya coincide con
    // stepsCompleted (== steps.length).
    final shown = intervened ? stepsCompleted + 1 : stepsCompleted;
    context.pushReplacement(
      '/closure',
      extra: {
        'situation': widget.situationId,
        'steps': stepsCompleted,
        'intervened': intervened,
        'level': _level,
        'variants': _variantOfStep.sublist(0, shown),
      },
    );
  }

  void _didIt(int totalSteps) {
    if (_step + 1 >= totalSteps) {
      _finish(stepsCompleted: totalSteps, intervened: false);
    } else {
      setState(() {
        _step++;
        _fallback = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final situation =
        situationById(ref.watch(situationsProvider), widget.situationId);
    final level = situation.levels[_level - 1];
    final steps = level.steps;
    final name = ref.watch(profileProvider)?.name ?? 'tu hijo';
    final step = steps[_step];
    final adjusting = _fallback >= 0;
    final hasMoreFallbacks = _fallback + 1 < step.fallbacks.length;
    final text = (adjusting
            ? step.fallbacks[_fallback]
            : step.variants[_variantOfStep[_step]])
        .replaceAll('{n}', name);
    final accent = adjusting ? VinkoColors.adjust : VinkoColors.action;

    return Scaffold(
      appBar: AppBar(
        title: Text(situation.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Salir',
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: VinkoSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Barra de progreso: paso X de N.
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_step + 1) / steps.length,
                        minHeight: 8,
                        backgroundColor: VinkoColors.border,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Paso ${_step + 1} de ${steps.length}',
                    style: theme.labelLarge
                        ?.copyWith(color: VinkoColors.textSecondary),
                  ),
                ],
              ),
              // Nivel actual, solo si la situación tiene escalera.
              if (situation.levels.length > 1) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VinkoColors.actionSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Nivel $_level · ${level.label}',
                      style: theme.labelMedium?.copyWith(
                        color: VinkoColors.action,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // La voz de Vinko: una sola instrucción, grande.
              Breathing(
                child: VinkoCard(
                  padding: const EdgeInsets.all(28),
                  borderColor:
                      adjusting ? VinkoColors.adjust : VinkoColors.border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: PhosphorIcon(
                                PhosphorIconsFill.compass,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            adjusting ? 'Vinko · prueba esto' : 'Vinko',
                            style: theme.titleMedium?.copyWith(color: accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        text,
                        style: theme.headlineMedium?.copyWith(
                          fontSize: 26,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              VinkoPrimaryButton(
                label: 'Lo hizo',
                icon: PhosphorIconsFill.checkCircle,
                color: VinkoColors.success,
                onPressed: () => _didIt(steps.length),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: VinkoSecondaryButton(
                      label: adjusting ? 'Tampoco funcionó' : 'No funcionó',
                      foreground: VinkoColors.adjust,
                      onPressed: hasMoreFallbacks
                          ? () => setState(() => _fallback++)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VinkoSecondaryButton(
                      label: 'Intervenir',
                      foreground: VinkoColors.textSecondary,
                      onPressed: () =>
                          _finish(stepsCompleted: _step, intervened: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VinkoSpacing.screenPadding),
            ],
          ),
        ),
      ),
    );
  }
}

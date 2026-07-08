# Ajustes

**Ruta:** `/settings` (icono de engranaje en Home)
**Código:** [settings_screen.dart](../lib/features/settings/settings_screen.dart) · estado en [app_state.dart](../lib/core/state/app_state.dart#L156-L185)

## Opciones

| Fila | Acción |
|---|---|
| **Perfil del niño** | Muestra nombre y edad; abre el onboarding en modo edición (`/onboarding?edit=1`). |
| **Cambiar de hijo** | Diálogo de confirmación → `clearAll()` (borra *todas* las prefs) → vuelve al onboarding. No hay multi-perfil: cambiar de hijo destruye el progreso del anterior. |
| **Recompensas** | Navega a `/rewards` ([recompensas.md](recompensas.md)). |
| **Recordatorios** (switch) | Guarda el flag `set_reminders`. **Sin implementación**: no hay notificaciones locales todavía. El subtítulo promete "Un aviso por día, nada más". |
| **Texto grande** (switch) | Guarda `set_large_text`. Sí está implementado: [main.dart](../lib/main.dart#L33-L44) aplica `TextScaler.linear(1.2)` a toda la app vía el `builder` de `MaterialApp`. |
| **Ayuda** | Diálogo con el modo de uso: "Cuando pase algo, toca 'Necesito ayuda ahora'... Vinko no reemplaza tu criterio." |
| **Cerrar sesión** | Igual que Cambiar de hijo: confirmación → `clearAll()` → onboarding. Estilizado en naranja (acción con consecuencias). |

## Implementación

- `AppSettings` (`reminders`, `largeText`) con `copyWith`; `SettingsNotifier.update()` persiste en `shared_preferences`.
- Los dos flujos destructivos comparten el helper `_confirmReset`, que muestra un `AlertDialog` con "Cancelar" / "Sí, continuar" antes de llamar a `profileProvider.notifier.clearAll()`.
- `clearAll()` hace `prefs.clear()`: borra perfil, progreso, recompensas y ajustes de una sola vez.

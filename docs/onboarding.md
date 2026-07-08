# Onboarding — Perfil del niño

**Ruta:** `/onboarding` (con `?edit=1` para modo edición)
**Código:** [onboarding_screen.dart](../lib/features/onboarding/onboarding_screen.dart) · [child_profile.dart](../lib/core/models/child_profile.dart)

## Qué hace

Es la primera pantalla que ve el usuario. Recoge los datos mínimos del niño para personalizar la guía:

1. **Nombre** — campo de texto (obligatorio; el botón queda deshabilitado si está vacío). Se usa después en todas las instrucciones, reemplazando el marcador `{n}` de los guiones.
2. **Edad** — chips de 3 a 10 años (selección única, por defecto 5).
3. **¿Qué le cuesta más?** — chips multiselección con las situaciones del catálogo (todas menos "Otra situación"). Se guardan como `challenges` (lista de ids de situación) en el perfil.

Al tocar **Empezar** se guarda el perfil y se navega a Home con `context.go('/')`.

## Modo edición

Desde Ajustes → "Perfil del niño" se entra con `/onboarding?edit=1`. Diferencias:

- Muestra `AppBar` con título "Perfil del niño" y oculta la presentación de Vinko ("Soy Vinko...").
- Precarga los valores del perfil existente.
- El botón dice **Guardar** en lugar de Empezar.

## Redirección forzada

En [router.dart](../lib/app/router.dart#L19-L24) hay un `redirect` global: si `profileProvider` es `null` (no hay perfil guardado) y la ruta destino no es `/onboarding`, se redirige a `/onboarding`. Así ninguna pantalla puede abrirse sin perfil.

## Persistencia

`ChildProfile` se serializa a JSON (`{name, age, challenges}`) y se guarda en `shared_preferences` bajo la clave `child_profile` vía `ProfileNotifier.save()` ([app_state.dart](../lib/core/state/app_state.dart#L15-L32)).

## Notas

- Los `challenges` elegidos se guardan pero **hoy no se usan en ninguna otra pantalla** (ver [pendientes](pendientes-y-sugerencias.md)).
- `ProfileNotifier.clearAll()` borra *todas* las preferencias (no solo el perfil) y devuelve el estado a `null`, lo que dispara el redirect al onboarding. Lo usan "Cambiar de hijo" y "Cerrar sesión" en Ajustes.

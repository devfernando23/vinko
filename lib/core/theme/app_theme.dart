import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta oficial de Vinko. Sin rojo: los errores usan el naranja de ajuste.
abstract class VinkoColors {
  static const action = Color(0xFF4A90E2); // azul acción
  static const success = Color(0xFF6FCF97); // verde éxito
  static const adjust = Color(0xFFF2994A); // naranja ajuste
  static const background = Color(0xFFF7F9FC); // blanco roto
  static const text = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E9F0);
  static const surface = Colors.white;

  static const actionSoft = Color(0xFFEAF2FC); // azul al 10% aprox, fondos de ícono
  static const successSoft = Color(0xFFEAF8F0);
  static const adjustSoft = Color(0xFFFDF0E4);

  // Tiers de insignias
  static const copper = Color(0xFFB87352);
  static const silver = Color(0xFF9AA5B1);
  static const gold = Color(0xFFD9A441);
}

abstract class VinkoSpacing {
  static const double screenPadding = 20;
  static const double gap = 16;
  static const double radius = 16;
  static const double buttonHeight = 56;
}

/// Sombra suave estándar para tarjetas y botones.
List<BoxShadow> vinkoSoftShadow({double opacity = 0.06}) => [
      BoxShadow(
        color: const Color(0xFF1F2937).withValues(alpha: opacity),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];

abstract class VinkoTheme {
  /// Tipografía del padre: Public Sans, sobria.
  static TextTheme _textTheme() {
    final base = ThemeData.light().textTheme;
    return GoogleFonts.publicSansTextTheme(base).apply(
      bodyColor: VinkoColors.text,
      displayColor: VinkoColors.text,
    );
  }

  /// Fredoka: solo para pantallas de celebración del niño.
  static TextStyle celebration({
    double fontSize = 32,
    Color color = VinkoColors.text,
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.fredoka(fontSize: fontSize, color: color, fontWeight: weight);

  static ThemeData light() {
    final textTheme = _textTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: VinkoColors.background,
      colorScheme: const ColorScheme.light(
        primary: VinkoColors.action,
        onPrimary: Colors.white,
        secondary: VinkoColors.success,
        onSecondary: Colors.white,
        tertiary: VinkoColors.adjust,
        onTertiary: Colors.white,
        // Sin rojo: los estados de error usan el naranja de ajuste.
        error: VinkoColors.adjust,
        onError: Colors.white,
        surface: VinkoColors.surface,
        onSurface: VinkoColors.text,
        outline: VinkoColors.border,
      ),
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium:
            textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: VinkoColors.textSecondary,
          height: 1.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: VinkoColors.background,
        foregroundColor: VinkoColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: VinkoColors.text,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VinkoColors.action,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(VinkoSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VinkoSpacing.radius),
          ),
          elevation: 0,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VinkoColors.action,
          minimumSize: const Size.fromHeight(VinkoSpacing.buttonHeight),
          side: const BorderSide(color: VinkoColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VinkoSpacing.radius),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VinkoColors.textSecondary,
          textStyle:
              textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? VinkoColors.action
              : VinkoColors.border,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VinkoColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VinkoSpacing.radius),
          borderSide: const BorderSide(color: VinkoColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VinkoSpacing.radius),
          borderSide: const BorderSide(color: VinkoColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VinkoSpacing.radius),
          borderSide: const BorderSide(color: VinkoColors.action, width: 2),
        ),
        hintStyle: textTheme.bodyLarge
            ?.copyWith(color: VinkoColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: VinkoColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

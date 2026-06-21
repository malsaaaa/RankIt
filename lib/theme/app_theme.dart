import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0F0E17); // Obsidian black
  static const Color primary = Color(0xFF9D4EDD);    // Neon Violet
  static const Color secondary = Color(0xFF240046);  // Deep Purple
  static const Color accent = Color(0xFF00F5D4);     // Neon Teal/Cyan
  static const Color surface = Color(0x1F240046);    // Semi-transparent deep purple for card bases
  static const Color border = Color(0x33FFFFFF);     // Glass border (white with opacity)
  
  static const Color textPrimary = Color(0xFFFFFFFE);
  static const Color textSecondary = Color(0xFFA7A9BE);
  static const Color error = Color(0xFFFF5470);
  static const Color success = Color(0xFF2EC4B6);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.background,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
          titleMedium: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.outfit(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
        labelStyle: GoogleFonts.outfit(color: AppColors.textPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shadowColor: AppColors.primary.withOpacity(0.4),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final Color borderColor;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.borderColor = AppColors.border,
    this.color,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(opacity),
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

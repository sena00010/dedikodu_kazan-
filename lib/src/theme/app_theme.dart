import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF090A3A);
  static const violet = Color(0xFF6D4CFF);
  static const blue = Color(0xFF4157F6);
  static const pink = Color(0xFFFF5DAE);
  static const coral = Color(0xFFFF7A5F);
  static const peach = Color(0xFFFFD39A);
  static const lilac = Color(0xFFE8DDFF);
  static const paper = Color(0xFFFFFBF7);
  static const mint = Color(0xFFDFF8EF);
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: brightness,
      primary: AppColors.violet,
      secondary: AppColors.pink,
      tertiary: AppColors.coral,
    );
    final background = dark ? const Color(0xFF080921) : AppColors.paper;
    final surface = dark ? const Color(0xFF11133A) : const Color(0xFFFFFFFF);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme.copyWith(
        surface: surface,
        primaryContainer: dark ? const Color(0xFF26215F) : AppColors.lilac,
        secondaryContainer: dark ? const Color(0xFF4B1F50) : const Color(0xFFFFD8ED),
        tertiaryContainer: dark ? const Color(0xFF55291F) : const Color(0xFFFFE1CA),
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'System',
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : AppColors.ink,
        titleTextStyle: TextStyle(
          color: dark ? Colors.white : AppColors.ink,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: dark ? Colors.white : AppColors.ink,
            displayColor: dark ? Colors.white : AppColors.ink,
          ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF191B49) : const Color(0xFFF4F0FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dark ? const Color(0xFF2B2E63) : const Color(0xFFE3D9FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.violet, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: dark ? Colors.white : AppColors.ink,
          side: BorderSide(color: dark ? const Color(0xFF34376E) : const Color(0xFFD7CDFE)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: dark ? const Color(0xFF101238) : Colors.white,
        indicatorColor: dark ? const Color(0xFF2D2B68) : AppColors.lilac,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? (dark ? Colors.white : AppColors.ink)
                : (dark ? const Color(0xFFB7B9D6) : const Color(0xFF686A83)),
          ),
        ),
      ),
    );
  }
}

class AppGradients {
  static const gossip = LinearGradient(
    colors: [AppColors.ink, AppColors.violet, AppColors.pink, AppColors.coral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warm = LinearGradient(
    colors: [AppColors.pink, AppColors.coral, AppColors.peach],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

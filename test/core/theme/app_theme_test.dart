import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_order_management/core/theme/app_theme.dart';

void main() {
  group('Color Constants', () {
    test('primaryColor equals Color(0xFF1976D2)', () {
      expect(AppTheme.primaryColor, equals(const Color(0xFF1976D2)));
    });

    test('secondaryColor equals Color(0xFFFF9800)', () {
      expect(AppTheme.secondaryColor, equals(const Color(0xFFFF9800)));
    });

    test('errorColor equals Color(0xFFD32F2F)', () {
      expect(AppTheme.errorColor, equals(const Color(0xFFD32F2F)));
    });

    test('successColor equals Color(0xFF388E3C)', () {
      expect(AppTheme.successColor, equals(const Color(0xFF388E3C)));
    });

    test('warningColor equals Color(0xFFF57C00)', () {
      expect(AppTheme.warningColor, equals(const Color(0xFFF57C00)));
    });

    test('infoColor equals Color(0xFF0288D1)', () {
      expect(AppTheme.infoColor, equals(const Color(0xFF0288D1)));
    });

    test('backgroundColor equals Color(0xFFF5F5F5)', () {
      expect(AppTheme.backgroundColor, equals(const Color(0xFFF5F5F5)));
    });

    test('surfaceColor equals Colors.white', () {
      expect(AppTheme.surfaceColor, equals(Colors.white));
    });

    test('cardColor equals Colors.white', () {
      expect(AppTheme.cardColor, equals(Colors.white));
    });

    test('textPrimaryColor equals Color(0xFF212121)', () {
      expect(AppTheme.textPrimaryColor, equals(const Color(0xFF212121)));
    });

    test('textSecondaryColor equals Color(0xFF757575)', () {
      expect(AppTheme.textSecondaryColor, equals(const Color(0xFF757575)));
    });

    test('textDisabledColor equals Color(0xFFBDBDBD)', () {
      expect(AppTheme.textDisabledColor, equals(const Color(0xFFBDBDBD)));
    });

    test('dividerColor equals Color(0xFFE0E0E0)', () {
      expect(AppTheme.dividerColor, equals(const Color(0xFFE0E0E0)));
    });
  });

  group('Light Theme Properties', () {
    test('lightTheme is not null and is instance of ThemeData', () {
      expect(AppTheme.lightTheme, isNotNull);
      expect(AppTheme.lightTheme, isA<ThemeData>());
    });

    test('lightTheme.useMaterial3 is true', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });

    test('ColorScheme properties', () {
      final colorScheme = AppTheme.lightTheme.colorScheme;
      
      expect(colorScheme.brightness, equals(Brightness.light));
      expect(colorScheme.primary, equals(AppTheme.primaryColor));
      expect(colorScheme.secondary, equals(AppTheme.secondaryColor));
      expect(colorScheme.error, equals(AppTheme.errorColor));
      expect(colorScheme.surface, equals(AppTheme.surfaceColor));
      expect(colorScheme.background, equals(AppTheme.backgroundColor));
      expect(colorScheme.onPrimary, equals(Colors.white));
      expect(colorScheme.onSecondary, equals(Colors.white));
      expect(colorScheme.onError, equals(Colors.white));
      expect(colorScheme.onSurface, equals(AppTheme.textPrimaryColor));
      expect(colorScheme.onBackground, equals(AppTheme.textPrimaryColor));
    });
  });

  group('Light Theme - AppBar', () {
    test('appBarTheme properties', () {
      final appBarTheme = AppTheme.lightTheme.appBarTheme;
      
      expect(appBarTheme.backgroundColor, equals(AppTheme.primaryColor));
      expect(appBarTheme.foregroundColor, equals(Colors.white));
      expect(appBarTheme.elevation, equals(2));
      expect(appBarTheme.centerTitle, isTrue);
    });
  });

  group('Light Theme - Card', () {
    test('cardTheme properties', () {
      final cardTheme = AppTheme.lightTheme.cardTheme;
      
      expect(cardTheme.color, equals(AppTheme.cardColor));
      expect(cardTheme.elevation, equals(2));
      expect(cardTheme.margin, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
    });
  });

  group('Light Theme - Buttons', () {
    test('ElevatedButton style', () {
      final elevatedButtonStyle = AppTheme.lightTheme.elevatedButtonTheme.style;
      
      expect(elevatedButtonStyle?.backgroundColor?.resolve({}), equals(AppTheme.primaryColor));
      expect(elevatedButtonStyle?.foregroundColor?.resolve({}), equals(Colors.white));
      expect(elevatedButtonStyle?.padding?.resolve({}), equals(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)));
      expect(elevatedButtonStyle?.shape?.resolve({}), isA<RoundedRectangleBorder>());
    });

    test('OutlinedButton style', () {
      final outlinedButtonStyle = AppTheme.lightTheme.outlinedButtonTheme.style;
      
      expect(outlinedButtonStyle?.foregroundColor?.resolve({}), equals(AppTheme.primaryColor));
      expect(outlinedButtonStyle?.padding?.resolve({}), equals(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)));
      expect(outlinedButtonStyle?.shape?.resolve({}), isA<RoundedRectangleBorder>());
      
      // Test border side color
      final shape = outlinedButtonStyle?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(shape?.side.color, equals(AppTheme.primaryColor));
    });

    test('TextButton style', () {
      final textButtonStyle = AppTheme.lightTheme.textButtonTheme.style;
      
      expect(textButtonStyle?.foregroundColor?.resolve({}), equals(AppTheme.primaryColor));
      expect(textButtonStyle?.padding?.resolve({}), equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
      expect(textButtonStyle?.shape?.resolve({}), isA<RoundedRectangleBorder>());
    });
  });

  group('Light Theme - Input Decoration', () {
    test('border configurations', () {
      final inputDecorationTheme = AppTheme.lightTheme.inputDecorationTheme;
      
      // Check border radius for OutlineInputBorder
      final border = inputDecorationTheme.border as OutlineInputBorder?;
      expect(border?.borderRadius, equals(const BorderRadius.all(Radius.circular(8))));
      
      final enabledBorder = inputDecorationTheme.enabledBorder as OutlineInputBorder?;
      expect(enabledBorder?.borderRadius, equals(const BorderRadius.all(Radius.circular(8))));
      
      final focusedBorder = inputDecorationTheme.focusedBorder as OutlineInputBorder?;
      expect(focusedBorder?.borderRadius, equals(const BorderRadius.all(Radius.circular(8))));
      expect(focusedBorder?.borderSide.width, equals(2));
      expect(focusedBorder?.borderSide.color, equals(AppTheme.primaryColor));
      
      final errorBorder = inputDecorationTheme.errorBorder as OutlineInputBorder?;
      expect(errorBorder?.borderRadius, equals(const BorderRadius.all(Radius.circular(8))));
      expect(errorBorder?.borderSide.color, equals(AppTheme.errorColor));
    });

    test('contentPadding and text styles', () {
      final inputDecorationTheme = AppTheme.lightTheme.inputDecorationTheme;
      
      expect(inputDecorationTheme.contentPadding, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));
      expect(inputDecorationTheme.hintStyle?.color, equals(AppTheme.textSecondaryColor));
      expect(inputDecorationTheme.labelStyle?.color, equals(AppTheme.textPrimaryColor));
    });
  });

  group('Light Theme - Text Theme', () {
    test('all text styles have correct properties', () {
      final textTheme = AppTheme.lightTheme.textTheme;
      
      // Display styles
      expect(textTheme.displayLarge?.fontSize, equals(32));
      expect(textTheme.displayLarge?.fontWeight, equals(FontWeight.bold));
      expect(textTheme.displayMedium?.fontSize, equals(28));
      expect(textTheme.displayMedium?.fontWeight, equals(FontWeight.bold));
      expect(textTheme.displaySmall?.fontSize, equals(24));
      expect(textTheme.displaySmall?.fontWeight, equals(FontWeight.bold));
      
      // Headline styles
      expect(textTheme.headlineLarge?.fontSize, equals(22));
      expect(textTheme.headlineLarge?.fontWeight, equals(FontWeight.bold));
      expect(textTheme.headlineMedium?.fontSize, equals(20));
      expect(textTheme.headlineMedium?.fontWeight, equals(FontWeight.bold));
      expect(textTheme.headlineSmall?.fontSize, equals(18));
      expect(textTheme.headlineSmall?.fontWeight, equals(FontWeight.bold));
      
      // Title styles
      expect(textTheme.titleLarge?.fontSize, equals(16));
      expect(textTheme.titleLarge?.fontWeight, equals(FontWeight.w600));
      expect(textTheme.titleMedium?.fontSize, equals(14));
      expect(textTheme.titleMedium?.fontWeight, equals(FontWeight.w600));
      expect(textTheme.titleSmall?.fontSize, equals(12));
      expect(textTheme.titleSmall?.fontWeight, equals(FontWeight.w600));
      
      // Body styles
      expect(textTheme.bodyLarge?.fontSize, equals(16));
      expect(textTheme.bodyLarge?.fontWeight, equals(FontWeight.normal));
      expect(textTheme.bodyMedium?.fontSize, equals(14));
      expect(textTheme.bodyMedium?.fontWeight, equals(FontWeight.normal));
      expect(textTheme.bodySmall?.fontSize, equals(12));
      expect(textTheme.bodySmall?.fontWeight, equals(FontWeight.normal));
      
      // Label styles
      expect(textTheme.labelLarge?.fontSize, equals(14));
      expect(textTheme.labelLarge?.fontWeight, equals(FontWeight.w500));
      expect(textTheme.labelMedium?.fontSize, equals(12));
      expect(textTheme.labelMedium?.fontWeight, equals(FontWeight.w500));
      expect(textTheme.labelSmall?.fontSize, equals(10));
      expect(textTheme.labelSmall?.fontWeight, equals(FontWeight.w500));
    });
  });

  group('Dark Theme Properties', () {
    test('darkTheme is not null and is instance of ThemeData', () {
      expect(AppTheme.darkTheme, isNotNull);
      expect(AppTheme.darkTheme, isA<ThemeData>());
    });

    test('darkTheme.useMaterial3 is true', () {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('ColorScheme properties', () {
      final colorScheme = AppTheme.darkTheme.colorScheme;
      
      expect(colorScheme.brightness, equals(Brightness.dark));
      expect(colorScheme.primary, equals(AppTheme.primaryColor));
      expect(colorScheme.secondary, equals(AppTheme.secondaryColor));
      expect(colorScheme.error, equals(AppTheme.errorColor));
      expect(colorScheme.surface, equals(const Color(0xFF121212)));
      expect(colorScheme.background, equals(const Color(0xFF121212)));
      expect(colorScheme.onPrimary, equals(Colors.white));
      expect(colorScheme.onSecondary, equals(Colors.white));
      expect(colorScheme.onError, equals(Colors.white));
      expect(colorScheme.onSurface, equals(Colors.white));
      expect(colorScheme.onBackground, equals(Colors.white));
    });
  });

  group('Dark Theme - AppBar', () {
    test('appBarTheme properties', () {
      final appBarTheme = AppTheme.darkTheme.appBarTheme;
      
      expect(appBarTheme.backgroundColor, equals(const Color(0xFF1E1E1E)));
      expect(appBarTheme.foregroundColor, equals(Colors.white));
      expect(appBarTheme.elevation, equals(2));
      expect(appBarTheme.centerTitle, isTrue);
    });
  });

  group('Dark Theme - Card', () {
    test('cardTheme properties', () {
      final cardTheme = AppTheme.darkTheme.cardTheme;
      
      expect(cardTheme.color, equals(const Color(0xFF1E1E1E)));
      expect(cardTheme.elevation, equals(2));
      expect(cardTheme.margin, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
    });
  });

  group('Dark Theme - Text Theme', () {
    test('key text styles have correct colors', () {
      final textTheme = AppTheme.darkTheme.textTheme;
      
      // Check that text colors are appropriate for dark theme
      expect(textTheme.displayLarge?.color, equals(Colors.white));
      expect(textTheme.headlineLarge?.color, equals(Colors.white));
      expect(textTheme.titleLarge?.color, equals(Colors.white));
      expect(textTheme.bodyLarge?.color, equals(Colors.white));
    });

    test('fontSize and fontWeight match light theme counterparts', () {
      final lightTextTheme = AppTheme.lightTheme.textTheme;
      final darkTextTheme = AppTheme.darkTheme.textTheme;
      
      expect(darkTextTheme.displayLarge?.fontSize, equals(lightTextTheme.displayLarge?.fontSize));
      expect(darkTextTheme.displayLarge?.fontWeight, equals(lightTextTheme.displayLarge?.fontWeight));
      expect(darkTextTheme.headlineLarge?.fontSize, equals(lightTextTheme.headlineLarge?.fontSize));
      expect(darkTextTheme.headlineLarge?.fontWeight, equals(lightTextTheme.headlineLarge?.fontWeight));
      expect(darkTextTheme.titleLarge?.fontSize, equals(lightTextTheme.titleLarge?.fontSize));
      expect(darkTextTheme.titleLarge?.fontWeight, equals(lightTextTheme.titleLarge?.fontWeight));
    });
  });

  group('Theme Consistency', () {
    test('both themes use the same button padding values', () {
      final lightButtonStyle = AppTheme.lightTheme.elevatedButtonTheme.style;
      final darkButtonStyle = AppTheme.darkTheme.elevatedButtonTheme.style;
      
      expect(lightButtonStyle?.padding?.resolve({}), equals(darkButtonStyle?.padding?.resolve({})));
    });

    test('both themes use the same border radius (8)', () {
      final lightInputBorder = AppTheme.lightTheme.inputDecorationTheme.border as OutlineInputBorder?;
      final darkInputBorder = AppTheme.darkTheme.inputDecorationTheme.border as OutlineInputBorder?;
      
      expect(lightInputBorder?.borderRadius, equals(const BorderRadius.all(Radius.circular(8))));
      expect(darkInputBorder?.borderRadius, equals(const BorderRadius.all(Radius.circular(8))));
    });

    test('both themes have matching text style font sizes', () {
      final lightTextTheme = AppTheme.lightTheme.textTheme;
      final darkTextTheme = AppTheme.darkTheme.textTheme;
      
      expect(darkTextTheme.displayLarge?.fontSize, equals(lightTextTheme.displayLarge?.fontSize));
      expect(darkTextTheme.headlineLarge?.fontSize, equals(lightTextTheme.headlineLarge?.fontSize));
      expect(darkTextTheme.titleLarge?.fontSize, equals(lightTextTheme.titleLarge?.fontSize));
      expect(darkTextTheme.bodyLarge?.fontSize, equals(lightTextTheme.bodyLarge?.fontSize));
    });
  });
}
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  applyElevationOverlayColor: false,
  visualDensity: VisualDensity.compact,
  // colorScheme: const ColorScheme.light(
  //   primary: Color(0xff6750a4),
  //   onPrimary: Colors.white,
  //   primaryContainer: Color(0xffeaddff),
  //   onPrimaryContainer: Color(0xff4f378b),
  //   secondary: Color(0xff625b71),
  //   onSecondary: Colors.white,
  //   secondaryContainer: Color(0xffe8def8),
  //   onSecondaryContainer: Color(0xff4a4458),
  //   tertiary: Color(0xff7d5260),
  //   onTertiary: Colors.white,
  //   tertiaryContainer: Color(0xffffd8e4),
  //   onTertiaryContainer: Color(0xff633b48),
  //   error: Color(0xffb3261e),
  //   onError: Colors.white,
  //   errorContainer: Color(0xfff9dedc),
  //   onErrorContainer: Color(0xff8c1d18),
  //   surface: Color(0xfffef7ff),
  //   onSurface: Color(0xff1d1b20),
  //   surfaceContainerHighest: Color(0xfff3edf7),
  //   outline: Color(0xff79747e),
  // ),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xff381e72),
    onPrimary: Color(0xffe9ddff),
    primaryContainer: Color(0xffe8dfff),
    secondary: Color(0xff4a4458),
    onSecondary: Color(0xffffffff),
    secondaryContainer: Color(0xffe8def8),
    tertiary: Color(0xff7d5260),
    onTertiary: Color(0xffffffff),
    tertiaryContainer: Color(0xffffd8e4),
    error: Color(0xffb3261e),
    onError: Color(0xffffffff),
    errorContainer: Color(0xfff9dedc),
    outline: Color(0xff79747e),
    surface: Color(0xfffef7ff),
    onSurface: Color(0xff1d1b20),
    surfaceContainerHighest: Color(0xffe6e0e9),
    onSurfaceVariant: Color(0xff49454f),
    inverseSurface: Color(0xff322f35),
    onInverseSurface: Color(0xfff5eff7),
    shadow: Color(0xff000000),
    scrim: Color(0xff000000),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: Color(0xff1d1b20),
    ),
    // Add other text styles similarly
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Color(0xdd000000),
    ),
    labelLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Color(0xdd000000),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff6750a4),
      foregroundColor: Colors.white,
      minimumSize: const Size(350, 45),
      elevation: 2,
      shape: const StadiumBorder(),
      shadowColor: Colors.black,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return const Color(0x1affffff);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0x14ffffff);
        }
        return null;
      }),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xff9585bf),
    selectedItemColor: Color(0xff6750a4),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    ),
    filled: false,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  ),
  scaffoldBackgroundColor: const Color(0xfffef7ff),
  // cardColor: const Color(0xfffef7ff),
  dividerColor: const Color(0xff79747e),
  iconTheme: const IconThemeData(color: Color(0xdd000000)),
  primaryIconTheme: const IconThemeData(color: Colors.white),
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xfffef7ff)),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  visualDensity: VisualDensity.compact,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xffd0bcff),
    onPrimary: Color(0xff381e72),
    primaryContainer: Color(0xff4f378b),
    secondary: Color(0xffccc2dc),
    onSecondary: Color(0xff332d41),
    secondaryContainer: Color(0xff4a4458),
    tertiary: Color(0xffefb8c8),
    onTertiary: Color(0xff492532),
    tertiaryContainer: Color(0xff633b48),
    error: Color(0xfff2b8b5),
    onError: Color(0xff601410),
    errorContainer: Color(0xff8c1d18),
    outline: Color(0xff938f99),
    surface: Color(0xff141218),
    onSurface: Color(0xffe6e0e9),
    surfaceContainerHighest: Color(0xff49454f),
  ),
  scaffoldBackgroundColor: const Color(0xff141218),
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xff141218)),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontFamily: 'Roboto',
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontFamily: 'Roboto',
      letterSpacing: 0.25,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      fontFamily: 'Roboto',
      letterSpacing: 0.15,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontFamily: 'Roboto',
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xffbcbbbd),
    selectedItemColor: Color(0xff6750a4),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    ),
    filled: false,
  ),
  iconTheme: const IconThemeData(color: Color(0xdd000000)),
  dividerColor: const Color(0xff938f99),
  buttonTheme: const ButtonThemeData(
    height: 36,
    minWidth: 88,
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.elliptical(2, 2)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffd0bcff), // Default button color
      foregroundColor: const Color(0xff381e72), // Text/icon color
      minimumSize: const Size(350, 45), // Button size
      elevation: 2, // Default elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // Button shape
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x1ee6e0e9); // Disabled color
        }
        return const Color(0xffd0bcff);
      }),
      elevation: WidgetStateProperty.resolveWith<double>((states) {
        if (states.contains(WidgetState.pressed)) return 8;
        if (states.contains(WidgetState.hovered)) return 4;
        return 2;
      }),
    ),
  ),
);

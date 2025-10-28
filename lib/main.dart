import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meals/screens/tabs.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 255, 87, 34), // Vibrant deep orange
  ).copyWith(
    primary: const Color.fromARGB(255, 255, 87, 34),
    secondary: const Color.fromARGB(255, 255, 171, 64),
    tertiary: const Color.fromARGB(255, 156, 39, 176),
    surface: const Color.fromARGB(255, 18, 18, 18),
    background: const Color.fromARGB(255, 12, 12, 12),
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
  cardTheme: CardTheme(
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
  ),
);

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: const TabsScreen(),
    );
  }
}
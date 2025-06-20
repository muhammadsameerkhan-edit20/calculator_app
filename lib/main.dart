// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/calculator_provider.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalculatorProvider(),
      child: Consumer<CalculatorProvider>( // Use Consumer to rebuild on theme change
        builder: (context, calculator, child) {
          return MaterialApp(
            title: 'Scientific Calculator',
            debugShowCheckedModeBanner: false,
            themeMode: calculator.themeMode, // Get themeMode from provider
            theme: ThemeData( // Light Theme
              brightness: Brightness.light,
              primaryColor: Colors.blue, // Example light theme primary
              scaffoldBackgroundColor: const Color(0xFFF0F0F0),
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.blueAccent,
                surface: Colors.white,
                background: const Color(0xFFF0F0F0),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.black87,
                onBackground: Colors.black87,
                brightness: Brightness.light,
                error: Colors.redAccent,
                onError: Colors.white,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color for light theme
                  foregroundColor: Colors.white,      // Text color for light theme buttons
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
                ),
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: Colors.black87),
                headlineSmall: TextStyle(fontSize: 28.0, color: Colors.black54),
                titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500, color: Colors.black87), // For button text
              ),
            ),
            darkTheme: ThemeData( // Dark Theme (similar to your previous one)
              brightness: Brightness.dark,
              primaryColor: Colors.orangeAccent,
              scaffoldBackgroundColor: const Color(0xFF202020),
              colorScheme: ColorScheme.dark(
                primary: Colors.orangeAccent,
                secondary: Colors.orange,
                surface: const Color(0xFF303030), // Card/dialog backgrounds
                background: const Color(0xFF202020),
                onPrimary: Colors.black,
                onSecondary: Colors.black,
                onSurface: Colors.white,
                onBackground: Colors.white,
                brightness: Brightness.dark,
                error: Colors.red,
                onError: Colors.white,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF282828), // Darker app bar
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF424242), // Default button for dark
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
                ),
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: Colors.white),
                headlineSmall: TextStyle(fontSize: 28.0, color: Colors.white70),
                titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500, color: Colors.white), // For button text
              ),
            ),
            home: const CalculatorScreen(),
          );
        },
      ),
    );
  }
}
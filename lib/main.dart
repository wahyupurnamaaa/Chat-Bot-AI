import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/app_store.dart';
import 'screens/onboarding.dart';
import 'screens/home.dart';
import 'widgets/brand.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SparkApp(store: AppStore(await SharedPreferences.getInstance())));
}

class SparkApp extends StatelessWidget {
  final AppStore store;
  const SparkApp({super.key, required this.store});
  ThemeData theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: purple,
      brightness: brightness,
      primary: dark ? const Color(0xFF9C88FF) : purple,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF171719) : Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF242427) : const Color(0xFFF6F5FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? const Color(0xFF242427) : const Color(0xFFF6F5FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      title: 'Nova AI',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
      home: store.signedIn
          ? HomeScreen(store: store)
          : OnboardingScreen(store: store),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durey/core/supabase/supabase_config.dart';
import 'package:durey/services/admob_service.dart';
import 'package:durey/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (skip on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize Supabase with production credentials
  await SupabaseConfig.initialize();

  // Initialize Google Mobile Ads (only on mobile platforms)
  if (!kIsWeb) {
    await AdMobService.initialize();
  }

  // Run the app wrapped with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: DuReyApp(),
    ),
  );
}

class DuReyApp extends StatelessWidget {
  const DuReyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DuRey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Kurdish',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Kurdish',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

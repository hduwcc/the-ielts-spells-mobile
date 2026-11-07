import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/audio_service.dart';
import 'core/theme/app_theme.dart';
import 'features/app_version/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI navigation and status bar style (Dark icons for light theme)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Audio & Sound effects
  await AudioService.init();

  runApp(
    const ProviderScope(
      child: IeltsSpellsMobileApp(),
    ),
  );
}

class IeltsSpellsMobileApp extends StatelessWidget {
  const IeltsSpellsMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The IELTS Spells',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

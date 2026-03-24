import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/arcade_theme.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: ArcadeColors.void_,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const FlashcardsArcadeApp());
}

class FlashcardsArcadeApp extends StatelessWidget {
  const FlashcardsArcadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards Arcade',
      debugShowCheckedModeBanner: false,
      theme: ArcadeTheme.dark,
      home: const LoginScreen(),
    );
  }
}

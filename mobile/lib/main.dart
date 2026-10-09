import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Blocks screenshots/screen recording on Android (FLAG_SECURE under the hood).
  // iOS cannot block capture outright — no_screenshot only detects recording there.
  await NoScreenshot.instance.screenshotOff();
  runApp(const CoachingApp());
}

class CoachingApp extends StatelessWidget {
  const CoachingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coaching',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const LoginScreen(),
    );
  }
}

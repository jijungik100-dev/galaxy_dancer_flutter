import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const GalaxyDancerApp());
}

class GalaxyDancerApp extends StatelessWidget {
  const GalaxyDancerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우주대스타',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030312),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00F5FF)),
      ),
      home: const GameScreen(),
    );
  }
}

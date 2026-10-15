import 'package:flutter/material.dart';
import 'package:spr0ut/spr0ut.dart';

import 'config/home_prefs.dart';
import 'config/theme.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Spr0utRoster.instance.load();
  await AuthService.instance.init();
  runApp(const GroveApp());
}

class GroveApp extends StatelessWidget {
  const GroveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HomePrefs.instance,
      builder: (context, _) {
        final dark = HomePrefs.instance.dark;
        return MaterialApp(
          title: 'gr0ve',
          debugShowCheckedModeBanner: false,
          theme: GroveTheme.light(),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          routes: {
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}

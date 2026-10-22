import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/reward_provider.dart';
import 'providers/session_timer_provider.dart';
import 'providers/custom_task_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/aac_provider.dart';
import 'providers/theme_provider.dart';

import 'services/notification_service.dart';

import 'ui/screens/session_timeout_screen.dart';
import 'ui/screens/splash_screen.dart'; // <-- Beimportáljuk a SplashScreen-t

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => SessionTimerProvider()),
        ChangeNotifierProvider(create: (_) => CustomTaskProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => AacProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProv, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Iránytű',
          themeMode: themeProv.themeMode,
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          home: Consumer<SessionTimerProvider>(
            builder: (context, timerProv, child) {
              if (timerProv.isTimeUp) {
                return const SessionTimeoutScreen();
              }
              // Itt indítjuk a Splash / Intro képernyőt a HomeScreen helyett:
              return const SplashScreen();
            },
          ),
        );
      },
    );
  }
}

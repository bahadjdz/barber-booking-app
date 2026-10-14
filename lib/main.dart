import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BarberBookingApp());
}

class BarberBookingApp extends StatelessWidget {
  const BarberBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoldenBlade',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: const Locale('ar', 'DZ'),
      supportedLocales: const [
        Locale('ar', 'DZ'),
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}

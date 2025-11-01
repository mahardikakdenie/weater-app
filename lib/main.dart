import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/screens/get_started_screen.dart';
import 'package:weather_app/screens/login_or_guest_screen.dart';
import 'package:weather_app/screens/my_home_page.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale 'id_ID' untuk DateFormat
  await initializeDateFormatting('id_ID');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // ← Mulai dari route '/'
      routes: {
        '/': (context) => const GetStartedScreen(),
        '/login': (context) => const LoginOrGuestScreen(),
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}

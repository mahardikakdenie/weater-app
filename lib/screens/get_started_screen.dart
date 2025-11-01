// lib/screens/get_started_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/screens/login_or_guest_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<bool> isAccessTokenValid(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://oauth2.googleapis.com/tokeninfo?access_token=$accessToken',
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }

  Future<void> _checkExistingSession() async {
    final googleSignIn = GoogleSignIn();
    final currentUser = googleSignIn.currentUser;

    if (currentUser != null) {
      try {
        final auth = await currentUser.authentication;
        if (auth.accessToken != null) {
          final isValid = await isAccessTokenValid(auth.accessToken!);
          if (isValid && mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
            return;
          }
        }
      } catch (e) {
        debugPrint("Auth error: $e");
      }
    }

    if (mounted) {
      setState(() {
        // Untuk hindari navigasi ganda
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔲 Hilangkan background default (putih di light mode)
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F0C29), // Lebih gelap, cocok untuk dark mode
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/weather_icon.png',
                width: 200,
                height: 200,
                // Opsional: pastikan ikon terlihat baik di dark mode
              ),
              const SizedBox(height: 32),
              const Text(
                'Weather',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Pastikan teks putih
                ),
              ),
              const Text(
                'ForeCasts',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFD700), // Emas tetap bagus di dark
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginOrGuestScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black, // Teks hitam di tombol emas
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  // ✅ Pastikan efek tap juga gelap
                  elevation: 4,
                  shadowColor: Colors.black54,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

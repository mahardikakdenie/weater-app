// lib/screens/login_or_guest_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginOrGuestScreen extends StatelessWidget {
  const LoginOrGuestScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      if (googleAuth.accessToken != null) {
        await prefs.setString("token", googleAuth.accessToken!);
      }

      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.toString().split('(').first}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Penting: hindari latar putih default
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F0C29), // Lebih gelap & modern
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to\nWeather ForeCasts!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 48),

                // 🔷 Login with Google — tetap emas, tapi dengan teks hitam yang jelas
                ElevatedButton.icon(
                  onPressed: () => _signInWithGoogle(context),
                  icon: const Icon(Icons.login, color: Colors.black),
                  label: const Text(
                    'Login with Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700), // Emas
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // 🔸 Email login — teks putih lembut
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email login coming soon'),
                        backgroundColor: Color(0xFF2A2D3E),
                      ),
                    );
                  },
                  child: const Text(
                    'Login with Email',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// lib/screens/my_home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _userName = '';
  final String _currentLocation = "Jakarta, ID";
  final double _currentTemp = 31.0;
  final String _weatherCondition = "Hujan Ringan";
  final String _weatherIcon = "🌧️";

  // Warna dinamis berdasarkan cuaca
  Color _getTempColor() {
    if (_weatherIcon.contains('☀') || _weatherIcon.contains('🌤')) {
      return const Color(0xFFFF6B35); // Oranye hangat
    } else if (_weatherIcon.contains('🌧') || _weatherIcon.contains('⛈')) {
      return const Color(0xFF4A90E2); // Biru sejuk
    } else {
      return Theme.of(context).colorScheme.onSurface; // Default
    }
  }

  // Dummy data: 5-day forecast
  final List<Map<String, dynamic>> _forecast = [
    {"day": "Hari Ini", "icon": "🌧️", "high": 32, "low": 25},
    {"day": "Senin", "icon": "⛈️", "high": 30, "low": 24},
    {"day": "Selasa", "icon": "🌦️", "high": 29, "low": 23},
    {"day": "Rabu", "icon": "🌤️", "high": 31, "low": 24},
    {"day": "Kamis", "icon": "☀️", "high": 33, "low": 26},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final guestId = prefs.getString('guest_id');

    if (mounted) {
      setState(() {
        _userName = isLoggedIn
            ? (FirebaseAuth.instance.currentUser?.displayName ??
                  FirebaseAuth.instance.currentUser?.email ??
                  'User')
            : 'Guest_${guestId?.substring(0, 6) ?? '000'}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4B0082),
              const Color(0xFF9932CC),
              const Color(0xFFBA55D3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Greeting
                Text(
                  'Hello, $_userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Current Weather Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentLocation,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _weatherCondition,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_currentTemp.toInt()}°',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: _getTempColor(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _weatherIcon,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Forecast Section
                const Text(
                  'Prakiraan 5 Hari',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 110,
                  child: Wrap(
                    spacing: 16, // jarak horizontal antar item
                    runSpacing: 12, // jarak vertikal antar baris (opsional)
                    runAlignment: WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    children: _forecast.map((day) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF8F9FF), Color(0xFFFFFFFF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day['day'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                day['icon'] as String,
                                style: const TextStyle(
                                  fontSize: 32,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${day['high']}°',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${day['low']}°',
                                style: const TextStyle(
                                  color: Color(0xFF6E7580),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 500), // Ruang untuk FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Tambah kota favorit',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur: Tambah kota favorit'),
                  backgroundColor: Colors.white,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add, size: 28),
            label: const Text(
              'Tambah Kota',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

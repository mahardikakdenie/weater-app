// lib/screens/my_home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/repository/weather_repository.dart';
import 'package:weather_app/screens/get_started_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _userName = '';
  String? _userPhotoUrl;
  String _currentLocation = "Mengambil lokasi...";
  late double _currentTemp = 0.0;
  late String _weatherCondition = "Memuat...";
  late WeatherResponse weather = WeatherResponse();

  List<String> _favoriteCities = ['Jakarta'];
  final TextEditingController _cityController = TextEditingController();

  final List<String> _allCities = [
    'Jakarta',
    'Bandung',
    'Surabaya',
    'Medan',
    'Makassar',
    'Semarang',
    'Palembang',
    'Denpasar',
    'Yogyakarta',
    'Balikpapan',
    'Tokyo',
    'Seoul',
    'Bangkok',
    'Singapore',
    'Kuala Lumpur',
    'London',
    'New York',
    'Paris',
  ];

  // Mock hourly forecast — nanti bisa ganti dengan API 5-day/hourly
  final List<Map<String, dynamic>> _hourlyForecast = [
    {"time": "05:00", "icon": "🌧️", "temp": 23},
    {"time": "06:00", "icon": "⛅", "temp": 20},
    {"time": "07:00", "icon": "🌧️", "temp": 17},
    {"time": "08:00", "icon": "🌧️", "temp": 16},
    {"time": "09:00", "icon": "🌤️", "temp": 18},
    {"time": "10:00", "icon": "☀️", "temp": 21},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavoriteCities();
    _fetchWeather();
  }

  void _fetchWeather() async {
    try {
      final response = await WeatherRepository.getCurrentWeather(
        lat: "-6.1636",
        lon: "106.7278",
        apiKey: 'ea5e57629b00206a154c5eeb3dade93e',
      );

      if (mounted) {
        setState(() {
          weather = response;
          _currentLocation =
              "${weather.name ?? 'Unknown'}, ${weather.sys?.country ?? ''}";
          _currentTemp = weather.main?.temp ?? 0.0;
          _weatherCondition = weather.weather?.isNotEmpty == true
              ? weather.weather![0].main
              : 'Clear';
        });
      }
    } catch (e) {
      debugPrint('Error weather: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat cuaca: $e')));
      }
    }
  }

  Future<void> onRefresh() async {
    _fetchWeather();
  }

  // ... (fungsi _loadUserData, _loadFavoriteCities, _saveFavoriteCities tetap sama)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final guestId = prefs.getString('guest_id');

    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        if (isLoggedIn && user != null) {
          _userName = user.displayName ?? user.email ?? 'User';
          _userPhotoUrl = user.photoURL;
        } else {
          _userName = 'Guest_${guestId?.substring(0, 6) ?? '000'}';
          _userPhotoUrl = null;
        }
      });
    }
  }

  Future<void> _loadFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    final cities = prefs.getStringList('favorite_cities') ?? ['Jakarta'];
    if (mounted) {
      setState(() {
        _favoriteCities = cities;
      });
    }
  }

  Future<void> _saveFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_cities', _favoriteCities);
  }

  void _setLocation(String city) {
    setState(() {
      _currentLocation = city;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Lokasi diubah ke $city')));
  }

  // ... (fungsi _showAddCitySheet, _addCity, _removeCity, _handleLogout, _showLogoutDialog, _buildInitialsAvatar tetap sama)
  void _showAddCitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Text(
                'Tambah Kota Favorit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari kota...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3A3F50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF5D5FEF),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2D3E),
                ),
                onSubmitted: (value) => _addCity(value.trim()),
              ),
              const SizedBox(height: 16),
              const Text(
                'Saran Kota:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allCities.map((city) {
                  return FilterChip(
                    label: Text(
                      city,
                      style: const TextStyle(color: Colors.white),
                    ),
                    selected: _favoriteCities.contains(city),
                    selectedColor: const Color(0xFF5D5FEF),
                    backgroundColor: const Color(0xFF2A2D3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFF3A3F50)),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _addCity(city);
                      } else {
                        _removeCity(city);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kota Favorit Anda:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _favoriteCities.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada kota favorit',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _favoriteCities.length,
                        itemBuilder: (context, index) {
                          final city = _favoriteCities[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              city,
                              style: const TextStyle(color: Colors.white),
                            ),
                            leading: const Icon(
                              Icons.location_on,
                              color: Color(0xFF5D5FEF),
                            ),
                            onTap: () {
                              _setLocation(city);
                              Navigator.of(context).pop();
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.white70,
                              ),
                              onPressed: () => _removeCity(city),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addCity(String city) {
    if (city.isNotEmpty && !_favoriteCities.contains(city)) {
      setState(() {
        _favoriteCities.add(city);
      });
      _saveFavoriteCities();
      _cityController.clear();
    }
  }

  void _removeCity(String city) {
    if (city != 'Jakarta') {
      setState(() {
        _favoriteCities.remove(city);
      });
      _saveFavoriteCities();
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('guest_id');
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    String initials = "U";
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = name.substring(0, 1).toUpperCase();
      }
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFF5D5FEF),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // ✅ Helper: Format timestamp ke string WIB
  String _formatTimestampToLocal(int? timestamp, int? timezoneOffset) {
    if (timestamp == null) return '–';
    final utc = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    );
    final local = utc.add(
      Duration(seconds: timezoneOffset ?? 25200),
    ); // default WIB
    return DateFormat('dd MMMM yyyy, HH.mm', 'id_ID').format(local);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => _fetchWeather(),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _currentLocation,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // ✅ Tampilkan waktu lokal
                                      Text(
                                        _formatTimestampToLocal(
                                          weather.dt,
                                          weather.timezone,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _showAddCitySheet(context),
                                    child: const Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '${_currentTemp.toInt()}°',
                                style: const TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _weatherCondition,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildWeatherInfoCard(
                                    icon: Icons.water_drop,
                                    label: 'Kelembapan',
                                    value: '${weather.main?.humidity ?? 0}%',
                                  ),
                                  _buildWeatherInfoCard(
                                    icon: Icons.air,
                                    label: 'Kecepatan Angin',
                                    value:
                                        '${weather.wind?.speed.toStringAsFixed(1) ?? '0'} m/s',
                                  ),
                                  _buildWeatherInfoCard(
                                    icon: Icons.compress,
                                    label: 'Tekanan',
                                    value: '${weather.main?.pressure ?? 0} hPa',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Hourly Forecast (mock)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hourly Forecast',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _hourlyForecast.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final hour = _hourlyForecast[index];
                                  return Container(
                                    width: 80,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: .1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          hour['icon'] as String,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          hour['time'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${hour['temp']}°',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                physics: const BouncingScrollPhysics(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tomorrow Forecast (mock)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Besok',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.cloud,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Hujan Ringan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: const [
                                            Text(
                                              '↑ 32°',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '↓ 25°',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                // App Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hello, $_userName!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showLogoutDialog,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withValues(alpha: .2),
                            child: _userPhotoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _userPhotoUrl!,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return _buildInitialsAvatar(
                                              _userName,
                                            );
                                          },
                                    ),
                                  )
                                : _buildInitialsAvatar(_userName),
                          ),
                        ),
                      ],
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

  Widget _buildWeatherInfoCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

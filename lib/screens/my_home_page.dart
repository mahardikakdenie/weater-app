// lib/screens/my_home_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/repository/weather_repository.dart';
import 'package:weather_app/screens/get_started_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =============== SEARCH SCREEN ===============
class SearchScreen extends StatefulWidget {
  final List<String> favoriteCities;
  final Function(String) onCitySelected;
  final Function(String) onAddCity;
  final Function(String) onRemoveCity;

  const SearchScreen({
    super.key,
    required this.favoriteCities,
    required this.onCitySelected,
    required this.onAddCity,
    required this.onRemoveCity,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
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

  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = _allCities;
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCities);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredCities = _allCities);
    } else {
      setState(
        () => _filteredCities = _allCities
            .where((city) => city.toLowerCase().contains(query))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cari Kota',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
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
            ),
            const SizedBox(height: 16),
            const Text(
              'Semua Kota',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCities.length,
                itemBuilder: (context, index) {
                  final city = _filteredCities[index];
                  final isFavorite = widget.favoriteCities.contains(city);
                  return ListTile(
                    title: Text(
                      city,
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: Icon(
                      isFavorite ? Icons.favorite : Icons.location_on,
                      color: isFavorite ? Colors.red : const Color(0xFF5D5FEF),
                    ),
                    onTap: () => widget.onCitySelected(city),
                    trailing: isFavorite
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => widget.onRemoveCity(city),
                          )
                        : IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => widget.onAddCity(city),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============== MAIN SCREEN DENGAN BOTTOM NAV ===============
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan dummy, nanti diisi saat build
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan widget Home & Search punya akses ke state yang sama
    return MyHomePageWithState(
      onScreenChange: (index) {
        setState(() => _currentIndex = index);
      },
      currentIndex: _currentIndex,
    );
  }
}

// =============== HOME PAGE DENGAN STATE SHARING ===============
class MyHomePageWithState extends StatefulWidget {
  final int currentIndex;
  final Function(int) onScreenChange;

  const MyHomePageWithState({
    super.key,
    required this.currentIndex,
    required this.onScreenChange,
  });

  @override
  State<MyHomePageWithState> createState() => _MyHomePageWithStateState();
}

class _MyHomePageWithStateState extends State<MyHomePageWithState> {
  // ... semua variabel state dari MyHomePage asli
  String _userName = '';
  String? _userPhotoUrl;
  String _currentLocation = "Mengambil lokasi...";
  late double _currentTemp = 0.0;
  late String _weatherCondition = "Memuat...";
  late WeatherResponse weather = WeatherResponse();
  late bool _isFavorite = false;

  List<String> _favoriteCities = ['Jakarta'];
  final TextEditingController cityController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _currentLat = -6.1636;
  double _currentLon = 106.7278;

  // void _setLocation(String city, {double? lat, double? lon}) {
  //   setState(() {
  //     _currentLocation = city;
  //   });

  //   // Jika koordinat disediakan, fetch cuaca baru
  //   if (lat != null && lon != null) {
  //     _fetchWeather(lat: lat, lon: lon);
  //   } else {
  //     // Cari koordinat dari daftar kota (fallback)
  //     final cityData = _getCityCoordinates(city);
  //     if (cityData != null) {
  //       _fetchWeather(lat: cityData['lat'], lon: cityData['lon']);
  //     }
  //   }
  // }

  Map<String, dynamic>? _getCityCoordinates(String cityName) {
    final cityMap = {
      'Jakarta': {'lat': -6.2088, 'lon': 106.8456},
      'Bandung': {'lat': -6.9175, 'lon': 107.6191},
      'Surabaya': {'lat': -7.2575, 'lon': 112.7521},
      'Medan': {'lat': 3.5952, 'lon': 98.6722},
      'Makassar': {'lat': -5.1477, 'lon': 119.4327},
      'Semarang': {'lat': -6.9667, 'lon': 110.4167},
      'Palembang': {'lat': -2.9761, 'lon': 104.7754},
      'Denpasar': {'lat': -8.6705, 'lon': 115.2126},
      'Yogyakarta': {'lat': -7.7956, 'lon': 110.3695},
      'Balikpapan': {'lat': -1.2379, 'lon': 116.8529},
      'Tokyo': {'lat': 35.6895, 'lon': 139.6917},
      'Seoul': {'lat': 37.5665, 'lon': 126.9780},
      'Bangkok': {'lat': 13.7563, 'lon': 100.5018},
      'Singapore': {'lat': 1.3521, 'lon': 103.8198},
      'Kuala Lumpur': {'lat': 3.1390, 'lon': 101.6869},
      'London': {'lat': 51.5074, 'lon': -0.1278},
      'New York': {'lat': 40.7128, 'lon': -74.0060},
      'Paris': {'lat': 48.8566, 'lon': 2.3522},
    };
    return cityMap[cityName];
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavoriteCities();
    _fetchWeather().then((_) => _checkIfFavorite());
  }

  // ... semua fungsi dari MyHomePage asli (copy-paste di bawah)

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isFavorite = false);
      return;
    }

    String cityName = weather.name?.isNotEmpty == true
        ? weather.name!
        : _currentLocation.split(',').first.trim();

    if (cityName.isEmpty ||
        cityName == "Mengambil lokasi..." ||
        cityName == "Unknown") {
      cityName = "Jakarta";
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(cityName)
        .get();

    if (mounted) {
      debugPrint("Cek favorit untuk: '$cityName', exists: ${doc.exists}");
      setState(() => _isFavorite = doc.exists);
    }
  }

  Future<void> _fetchWeather({double? lat, double? lon}) async {
    final useLat = lat ?? _currentLat;
    final useLon = lon ?? _currentLon;

    try {
      final response = await WeatherRepository.getCurrentWeather(
        lat: useLat.toString(),
        lon: useLon.toString(),
        apiKey: 'ea5e57629b00206a154c5eeb3dade93e',
      );

      if (mounted) {
        setState(() {
          weather = response;
          _currentLocation =
              "${weather.name ?? 'Unknown'}, ${weather.sys?.country ?? ''}";
          _currentTemp = weather.main?.temp ?? 0.0;
          _currentLat = weather.coord?.lat ?? useLat;
          _currentLon = weather.coord?.lon ?? useLon;
          _weatherCondition = weather.weather?.isNotEmpty == true
              ? weather.weather![0].main
              : 'Clear';
        });
        // Cek favorit setelah cuaca dimuat
        _checkIfFavorite();
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

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk menyimpan favorit')),
      );
      return;
    }

    String cityName = weather.name?.isNotEmpty == true
        ? weather.name!
        : _currentLocation.split(',').first.trim();

    if (cityName.isEmpty ||
        cityName == "Mengambil lokasi..." ||
        cityName == "Unknown") {
      cityName = "Jakarta";
    }

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(cityName);

    if (_isFavorite) {
      await docRef.delete();
      if (mounted) setState(() => _isFavorite = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dihapus dari favorit: $cityName')),
      );
    } else {
      await docRef.set({
        'name': cityName,
        'country': weather.sys?.country ?? '',
        'lat': _currentLat, // ✅ gunakan state terkini
        'lon': _currentLon,
        "email": user.email,
        'addedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) setState(() => _isFavorite = true);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ditambahkan ke favorit: $cityName')),
      );
    }
  }

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

  void _setLocation(String city, {double? lat, double? lon}) {
    setState(() {
      _currentLocation = city;
    });

    // Jika koordinat disediakan, fetch cuaca baru
    if (lat != null && lon != null) {
      _fetchWeather(lat: lat, lon: lon);
    } else {
      // Cari koordinat dari daftar kota (fallback)
      final cityData = _getCityCoordinates(city);
      if (cityData != null) {
        _fetchWeather(lat: cityData['lat'], lon: cityData['lon']);
      }
    }
  }

  void _addCity(String city) {
    if (city.isNotEmpty && !_favoriteCities.contains(city)) {
      setState(() {
        _favoriteCities.add(city);
      });
      _saveFavoriteCities();
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

  String _formatTimestampToLocal(int? timestamp, int? timezoneOffset) {
    if (timestamp == null) return '–';
    final utc = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    );
    final local = utc.add(Duration(seconds: timezoneOffset ?? 25200));
    return DateFormat('dd MMMM yyyy, HH.mm', 'id_ID').format(local);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: widget.currentIndex,
        children: [
          // === HOME SCREEN ===
          Container(
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
                                        onTap: _toggleFavorite,
                                        child: Icon(
                                          Icons.favorite,
                                          color: _isFavorite
                                              ? Colors.red
                                              : Colors.white,
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
                                        value:
                                            '${weather.main?.humidity ?? 0}%',
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
                                        value:
                                            '${weather.main?.pressure ?? 0} hPa',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Hourly Forecast
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
                                    itemCount: 6,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final hour = {
                                        "time": "0${5 + index}:00",
                                        "icon": "☀️",
                                        "temp": 20 + index,
                                      };
                                      return Container(
                                        width: 80,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: .1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              hour['icon'] as String,
                                              style: const TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              hour['time'] as String,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
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
                          // Tomorrow Forecast
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
                                backgroundColor: Colors.white.withValues(
                                  alpha: .2,
                                ),
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
          // === SEARCH SCREEN ===
          SearchScreen(
            favoriteCities: _favoriteCities,
            onCitySelected: (city) {
              final coords = _getCityCoordinates(city);
              if (coords != null) {
                _setLocation(city, lat: coords['lat'], lon: coords['lon']);
              } else {
                _setLocation(city); // fallback
              }
              widget.onScreenChange(0);
            },
            onAddCity: _addCity,
            onRemoveCity: _removeCity,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onScreenChange,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E2F),
        selectedItemColor: const Color(0xFF5D5FEF),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}

// =============== EKSPOR UTAMA ===============
// Ganti route utama kamu ke MyHomePage
// Misal di main.dart: home: const MyHomePage()

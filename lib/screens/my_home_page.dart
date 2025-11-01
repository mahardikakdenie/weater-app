// lib/screens/my_home_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather_app/model/favorite_city_model.dart';
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/location_model.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/repository/location_repository.dart';
import 'package:weather_app/screens/get_started_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/timestamp_to_local.dart';
import 'package:weather_app/widgets/home_widget.dart';
import 'package:weather_app/widgets/search_widget.dart';

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
  String _userName = '';
  String? _userPhotoUrl;
  String _currentLocation = "Mengambil lokasi...";
  late double _currentTemp = 0.0;
  late String _weatherCondition = "Memuat...";
  late WeatherResponse weather = WeatherResponse();
  late ForecastResponse forecastResponse = ForecastResponse();
  late bool _isFavorite = false;
  late List<ForecastListItem> forecastList = [];
  bool _forecastLoading = true;
  late List<LocationModel> locations = [];

  List<String> _favoriteCities = [];
  List<FavoriteCity> _savedFavoriteCities = [];
  final TextEditingController cityController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _currentLat = -6.1636;
  double _currentLon = 106.7278;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavoriteCities();
    fetchFavorites();
    _getCurrentLocationThenWeather();
    requestLocationPermission(context);
  }

  Future<bool> requestLocationPermission(BuildContext context) async {
    // Cek status izin
    var status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    }

    // Minta izin pertama kali
    final result = await Permission.location.request();

    if (result.isGranted) {
      return true;
    }

    // Jika ditolak (dan bukan "permanently denied")
    if (result.isDenied) {
      // Tampilkan dialog edukasi
      await _showPermissionDeniedDialog(context);
      return false;
    }

    // Jika "permanently denied" → arahkan ke pengaturan
    if (result.isPermanentlyDenied) {
      await _showOpenSettingsDialog(context);
      return false;
    }

    return false;
  }

  // Dialog: Izin ditolak sementara
  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Lokasi Dibutuhkan'),
        content: const Text(
          'Aplikasi ini membutuhkan akses lokasi untuk menampilkan cuaca di daerah Anda. '
          'Silakan izinkan akses lokasi agar fitur ini berfungsi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              requestLocationPermission(context); // coba lagi
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // Dialog: Izin ditolak permanen → buka pengaturan
  Future<void> _showOpenSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Lokasi Dinonaktifkan'),
        content: const Text(
          'Anda telah menonaktifkan izin lokasi secara permanen. '
          'Silakan aktifkan manual di Pengaturan Aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Buka pengaturan aplikasi
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocationThenWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLat = position.latitude;
        _currentLon = position.longitude;
      });
      await _fetchWeather().then((_) => _checkIfFavorite());
      await _forecastWeather();
    } catch (e) {
      debugPrint("Gagal ambil lokasi: $e");
      await _fetchWeather().then((_) => _checkIfFavorite());
      await _forecastWeather();
    }
  }

  Future<void> fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isFavorite = false);
      return;
    }
    final querySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    final List<FavoriteCity> favorites = querySnapshot.docs
        .map((doc) => FavoriteCity.fromMap(doc.id, doc.data()))
        .toList();

    debugPrint("Jumlah favorit: ${favorites.length}");
    for (var fav in favorites) {
      debugPrint(" - $fav");
    }

    setState(() {
      _savedFavoriteCities = favorites;
    });
  }

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
        cityName == "fetching locations..." ||
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
      final response = await WeatherService.fetchWeatherData(
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

  String getWeatherIcon(String main) {
    switch (main) {
      case 'Clear':
        return '☀️';
      case 'Clouds':
        return '☁️';
      case 'Rain':
      case 'Drizzle':
        return '🌧️';
      case 'Thunderstorm':
        return '⛈️';
      case 'Snow':
        return '🌨️';
      case 'Mist':
      case 'Fog':
      case 'Haze':
      case 'Smoke':
        return '🌫️';
      default:
        return '❓';
    }
  }

  Future<void> _forecastWeather({double? lat, double? lon}) async {
    final useLat = lat ?? _currentLat;
    final useLon = lon ?? _currentLon;
    try {
      final response = await WeatherService.fetchForecastData(
        lat: useLat.toString(),
        lon: useLon.toString(),
        apiKey: 'ea5e57629b00206a154c5eeb3dade93e',
      );

      if (mounted) {
        forecastResponse = response;
        forecastList = filterTodayWeather(response.list ?? []);
        _forecastLoading = false;
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error Forecast: $e');
      if (mounted) {
        _forecastLoading = false;
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat prakiraan: $e')));
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
      setState(() {
        _savedFavoriteCities = _savedFavoriteCities
            .where((fav) => fav.name != cityName)
            .toList();
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dihapus dari favorit: $cityName')),
      );
    } else {
      await docRef.set({
        'name': cityName,
        'country': weather.sys?.country ?? '',
        'lat': _currentLat,
        'lon': _currentLon,
        "email": user.email,
        'addedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _savedFavoriteCities.add(
          FavoriteCity(
            id: docRef.id,
            name: cityName,
            lat: _currentLat,
            lon: _currentLon,
          ),
        );
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

    if (lat != null && lon != null) {
      _fetchWeather(lat: lat, lon: lon);
      _forecastWeather(lat: lat, lon: lon);
    }
  }

  void _addCity(LocationModel city) {
    if (city.name!.isNotEmpty && !_favoriteCities.contains(city.name)) {
      setState(() {
        _favoriteCities.add(city.name as String);
      });
      _saveFavoriteCities();
    }
  }

  void _addFavoriteCity(FavoriteCity city) {
    if (city.name.isNotEmpty && !_favoriteCities.contains(city.name)) {
      setState(() {
        _favoriteCities.add(city.name);
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
    // 1. Sign out dari Google
    await GoogleSignIn().signOut();

    // 2. Sign out dari Firebase
    await FirebaseAuth.instance.signOut();

    // 3. Hapus data lokal
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('guest_id');

    // 4. Navigasi
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: widget.currentIndex,
        children: [
          // === HOME SCREEN ===
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async => _fetchWeather(),
              child: HomeWidget(
                userName: _userName,
                userPhotoUrl: _userPhotoUrl,
                currentLocation: _currentLocation,
                currentTemp: _currentTemp,
                weatherCondition: _weatherCondition,
                weather: weather,
                forecastList: forecastList,
                forecastResponse: forecastResponse,
                isFavorite: _isFavorite,
                forecastLoading: _forecastLoading,
                onToggleFavorite: _toggleFavorite,
                onLogout: _handleLogout,
              ),
            ),
          ),
          // === SEARCH SCREEN ===
          SearchScreen(
            favoriteCities: _favoriteCities,
            filteredCities: locations,
            savedFavorites: _savedFavoriteCities,
            onCitySelected: (city) {
              _setLocation(city.name as String, lat: city.lat, lon: city.lon);
              widget.onScreenChange(0);
            },
            onFavoriteSelected: (city) {
              _setLocation(city.name, lat: city.lat, lon: city.lon);
              widget.onScreenChange(0);
            },
            onAddCity: _addCity,
            onAddFavorite: _addFavoriteCity,
            onRemoveCity: _removeCity,
            onSearch: (value) async {
              debugPrint("value : $value");

              var resp = await LocationRepository.getLocation(
                search: value,
                limit: "10",
              );
              setState(() {
                locations = resp;
              });
            },
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

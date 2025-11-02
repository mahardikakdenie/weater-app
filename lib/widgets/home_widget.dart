// lib/widgets/home_widget.dart

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/bloc/forecast/forecast_bloc.dart';
import 'package:weather_app/bloc/forecast/forecast_state.dart';
import 'package:weather_app/bloc/weather/weather_bloc.dart';
import 'package:weather_app/bloc/weather/weather_state.dart';
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/weather_model.dart' hide Wind;
import 'package:weather_app/utils/timestamp_to_local.dart';
import 'package:weather_app/widgets/avatar_widget.dart';
import 'package:weather_app/widgets/box_weather_loading.dart';
import 'package:weather_app/widgets/grid_loading.dart';
import 'package:weather_app/widgets/weather_info_card.dart';

class HomeWidget extends StatefulWidget {
  final String userName;
  final String? userPhotoUrl;
  final Function(WeatherResponse, bool) onToggleFavorite;
  final VoidCallback onLogout;

  const HomeWidget({
    super.key,
    required this.userName,
    required this.userPhotoUrl,
    required this.onToggleFavorite,
    required this.onLogout,
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
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

  List<ForecastListItem> filterTomorrowWeather(ForecastResponse response) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final tomorrowEnd = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day + 1,
    );

    return response.list?.where((item) {
          final itemTime = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000);
          return itemTime.isAfter(tomorrow) && itemTime.isBefore(tomorrowEnd);
        }).toList() ??
        [];
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late bool _isFavorite = false;

  Future<void> _checkIfFavorite({required WeatherResponse data}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isFavorite = false);
      return;
    }

    String cityName = data.name ?? '-';
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(cityName)
        .get();

    if (mounted) {
      setState(() => _isFavorite = doc.exists);
    }
  }

  Widget _buildEmptyForecast() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: Colors.white70, size: 32),
            const SizedBox(height: 8),
            Text(
              'No weather forecast available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: const Color(0xFF2D1B3A), // Dark purple
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Confirmation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Are you sure you want to log out?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onLogout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5E72E4), Color(0xFF825EE4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 100),

                // Weather Info Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: BlocBuilder<WeatherBloc, WeatherState>(
                          builder: (context, state) {
                            if (state is WeatherLoaded) {
                              WeatherResponse weatherData = state.weather;
                              _checkIfFavorite(data: weatherData);
                              String iconData = weatherData.weather!.isNotEmpty
                                  ? weatherData.weather![0].main as String
                                  : "Clear";
                              return Column(
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
                                            "${weatherData.name}, ${weatherData.sys?.country}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formatTimestampToLocal(
                                              weatherData.dt,
                                              weatherData.timezone,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () => widget.onToggleFavorite(
                                          weatherData,
                                          _isFavorite,
                                        ),
                                        child: AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          scale: _isFavorite ? 1.15 : 1.0,
                                          child: Icon(
                                            Icons.favorite,
                                            color: _isFavorite
                                                ? Colors.red
                                                : Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '${weatherData.main!.temp?.toInt()}°',
                                    style: const TextStyle(
                                      fontSize: 76,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    getWeatherIcon(iconData),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 56,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      WeatherInfoCard(
                                        icon: Icons.water_drop,
                                        label: 'Humidity',
                                        value:
                                            '${weatherData.main?.humidity ?? 0}%',
                                      ),
                                      WeatherInfoCard(
                                        icon: Icons.air,
                                        label: 'Wind Speed',
                                        value:
                                            '${weatherData.wind?.speed?.toStringAsFixed(1) ?? '0'} m/s',
                                      ),
                                      WeatherInfoCard(
                                        icon: Icons.compress,
                                        label: 'Pressure',
                                        value:
                                            '${weatherData.main?.pressure ?? 0} hPa',
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else if (state is WeatherLoading) {
                              return const BoxWeatherLoading();
                            }
                            return const BoxWeatherLoading();
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 120,
                    child: BlocBuilder<ForecastBloc, ForecastState>(
                      builder: (context, state) {
                        if (state is ForecastLoading) {
                          return const GridLoading();
                        }

                        if (state is ForecastLoaded) {
                          final forecastList = state.data.list ?? [];
                          if (forecastList.isEmpty) {
                            return _buildEmptyForecast();
                          }

                          return Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: forecastList.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final item = forecastList[index];
                                  return Container(
                                    width: 72,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          getWeatherIcon(item.weather[0].main),
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatTimestampToLocal(
                                            item.dt,
                                            state.data.city?.timezone ?? 25200,
                                            formatDate: 'HH.mm',
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.main.temp.toInt()}°',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                physics: const BouncingScrollPhysics(),
                              ),
                            ],
                          );
                        }

                        return const GridLoading();
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                BlocBuilder<ForecastBloc, ForecastState>(
                  builder: (context, forecastState) {
                    List<ForecastListItem> tomorrowList = [];
                    bool isLoading = true;

                    if (forecastState is ForecastLoaded) {
                      isLoading = false;
                      tomorrowList = filterTomorrowWeather(forecastState.data);
                    } else if (forecastState is! ForecastLoading) {
                      isLoading = false;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tomorrow's Details",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      if (tomorrowList.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              getWeatherIcon(
                                                tomorrowList
                                                    .first
                                                    .weather[0]
                                                    .main,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 32,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tomorrowList
                                                        .first
                                                        .weather[0]
                                                        .description
                                                        .split(" ")
                                                        .map(
                                                          (text) =>
                                                              text.capitalize(),
                                                        )
                                                        .join(" "),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '↑ ${tomorrowList.map((w) => w.main.tempMax).reduce(math.max).toInt()}°',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '↓ ${tomorrowList.map((w) => w.main.tempMin).reduce(math.min).toInt()}°',
                                                        style: const TextStyle(
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

                                      const SizedBox(height: 16),

                                      if (tomorrowList.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildDetailRow(
                                              Icons.thermostat,
                                              'Feels Like',
                                              '${tomorrowList.first.main.feelsLike.toInt()}°',
                                            ),
                                            _buildDetailRow(
                                              Icons.remove_red_eye,
                                              'Visibility',
                                              '${(tomorrowList.first.visibility) ~/ 1000} km',
                                            ),
                                            _buildDetailRow(
                                              Icons.cloud,
                                              'Cloud Cover',
                                              '${tomorrowList.first.clouds.all}%',
                                            ),
                                            _buildDetailRow(
                                              Icons.opacity,
                                              'UV Index',
                                              '–', // or 'N/A' if preferred
                                            ),
                                          ],
                                        )
                                      else
                                        const Center(
                                          child: Text(
                                            'Data not found',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
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
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5E72E4), Color(0xFF825EE4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello, ${widget.userName}!',
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
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: widget.userPhotoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                widget.userPhotoUrl!,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return AvatarWidget(name: widget.userName);
                                },
                              ),
                            )
                          : AvatarWidget(name: widget.userName),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

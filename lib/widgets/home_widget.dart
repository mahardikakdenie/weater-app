// lib/widgets/home_widget.dart

import 'dart:math' as math;
import 'dart:ui' as ui; // Untuk BackdropFilter

import 'package:flutter/material.dart';
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/weather_model.dart' hide Wind;
import 'package:weather_app/utils/timestamp_to_local.dart';
import 'package:weather_app/widgets/avatar_widget.dart';
import 'package:weather_app/widgets/weather_info_card.dart';

class HomeWidget extends StatelessWidget {
  final String userName;
  final String? userPhotoUrl;
  final String currentLocation;
  final double currentTemp;
  final String weatherCondition;
  final WeatherResponse weather;
  final ForecastResponse forecastResponse;
  final List<ForecastListItem> forecastList;
  final bool isFavorite;
  final bool forecastLoading;
  final VoidCallback onToggleFavorite;
  final VoidCallback onLogout;

  const HomeWidget({
    super.key,
    required this.userName,
    required this.userPhotoUrl,
    required this.currentLocation,
    required this.currentTemp,
    required this.weatherCondition,
    required this.weather,
    required this.forecastList,
    required this.forecastResponse,
    required this.isFavorite,
    required this.forecastLoading,
    required this.onToggleFavorite,
    required this.onLogout,
  });

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

  @override
  Widget build(BuildContext context) {
    final tomorrowList = filterTomorrowWeather(forecastResponse);

    Widget buildDetailRow(IconData icon, String label, String value) {
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

    void showLogoutDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[800],
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
                onLogout();
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          // Background Gradien
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5E72E4), Color(0xFF825EE4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Konten Scrollable
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 100),

                // Card Cuaca Utama
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentLocation,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatTimestampToLocal(
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
                                  onTap: onToggleFavorite,
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 200),
                                    scale: isFavorite ? 1.15 : 1.0,
                                    child: Icon(
                                      Icons.favorite,
                                      color: isFavorite
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
                              '${currentTemp.toInt()}°',
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
                              getWeatherIcon(weatherCondition),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                WeatherInfoCard(
                                  icon: Icons.water_drop,
                                  label: 'Kelembapan',
                                  value: '${weather.main?.humidity ?? 0}%',
                                ),
                                WeatherInfoCard(
                                  icon: Icons.air,
                                  label: 'Kecepatan Angin',
                                  value:
                                      '${weather.wind?.speed.toStringAsFixed(1) ?? '0'} m/s',
                                ),
                                WeatherInfoCard(
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
                  ),
                ),

                const SizedBox(height: 24),

                // Prakiraan Per Jam
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 120,
                    child: Stack(
                      children: [
                        // Garis dasar sebagai panduan visual
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        forecastLoading
                            ? ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: 6,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
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
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 40,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 30,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                physics: const BouncingScrollPhysics(),
                              )
                            : forecastList.isEmpty
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_off,
                                        color: Colors.white70,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tidak ada prakiraan cuaca',
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
                              )
                            : ListView.separated(
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
                                            25200,
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
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Detail Hari Ini atau Besok
                Padding(
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
                        child: forecastLoading
                            ? Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tomorrowList.isNotEmpty
                                        ? 'Tommorow'
                                        : 'Detail Today',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Tampilkan prakiraan besok jika ada
                                  if (tomorrowList.isNotEmpty)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          getWeatherIcon(
                                            tomorrowList.first.weather[0].main,
                                          ),
                                          style: const TextStyle(fontSize: 32),
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
                                                    .toLowerCase()
                                                    .split(' ')
                                                    .map((word) => word)
                                                    .join(' '),
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

                                  // Detail tambahan (selalu tampil)
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    // spacing: 10r,
                                    children: [
                                      buildDetailRow(
                                        Icons.thermostat,
                                        'Terasa seperti',
                                        '${weather.main?.feelsLike.toInt() ?? 0}°',
                                      ),
                                      buildDetailRow(
                                        Icons.remove_red_eye,
                                        'Jarak pandang',
                                        '${(weather.visibility ?? 10000) ~/ 1000} km',
                                      ),
                                      buildDetailRow(
                                        Icons.cloud,
                                        'Awan',
                                        '${weather.clouds?.all ?? 0}%',
                                      ),
                                      buildDetailRow(
                                        Icons.opacity,
                                        'UV Index',
                                        '–', // placeholder, bisa diisi jika API mendukung
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
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
                    'Halo, $userName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: showLogoutDialog,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: userPhotoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                userPhotoUrl!,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return AvatarWidget(name: userName);
                                },
                              ),
                            )
                          : AvatarWidget(name: userName),
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// lib/widgets/home_widget.dart

import 'package:flutter/material.dart';
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/weather_model.dart';
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

  @override
  Widget build(BuildContext context) {
    void showLogoutDialog() {
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentLocation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
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
                              child: Icon(
                                Icons.favorite,
                                color: isFavorite ? Colors.red : Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '${currentTemp.toInt()}°',
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          getWeatherIcon(weatherCondition),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
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
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    height: 120,
                    child: forecastLoading
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return Container(
                                width: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
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
                                        borderRadius: BorderRadius.circular(4),
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
                                        borderRadius: BorderRadius.circular(4),
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
                            scrollDirection: Axis.horizontal,
                            itemCount: forecastList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final hour = {
                                "time": formatTimestampToLocal(
                                  forecastList[index].dt,
                                  25200,
                                  formatDate: 'HH.mm',
                                ),
                                "icon": getWeatherIcon(
                                  forecastList[index].weather[0].main,
                                ),
                                "temp": forecastList[index].main.temp,
                              };
                              return Container(
                                width: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                ),
                const SizedBox(height: 24),
                // Tomorrow Forecast (hardcoded for now)
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
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
                    'Hello, $userName!',
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
                      backgroundColor: Colors.white.withValues(alpha: .2),
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

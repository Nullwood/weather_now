import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Текущая погода')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: WeatherService().fetchCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          }

          final weather = snapshot.data!;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${weather['temp'].round()}°',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text('💨 Ветер: ${weather['wind'].round()} м/с'),
                Text('🌧 Осадки: ${weather['precipitation']} мм'),
              ],
            ),
          );
        },
      ),
    );
  }
}

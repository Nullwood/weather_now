import 'package:flutter/material.dart';
import '../services/weather_service.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Текущая погода')),
      body: FutureBuilder(
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
                Text('${weather['temperature']}°C',
                    style: const TextStyle(fontSize: 48)),
                Text('Ветер: ${weather['windspeed']} м/с'),
              ],
            ),
          );
        },
      ),
    );
  }
}

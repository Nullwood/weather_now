import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/notification_service.dart';
import 'forecast_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkWeatherAlerts();
  }

  void _checkWeatherAlerts() async {
    try {
      final weather = await WeatherService().fetchCurrentWeather();
      final wind = (weather['wind'] as num).toDouble();
      final precip = (weather['precipitation'] as num).toDouble();

      if (wind > 10) {
        await NotificationService.showWeatherWarning(
          'Сильный ветер',
          'Скорость ветра: ${wind.toStringAsFixed(1)} м/с',
        );
      }

      if (precip > 5) {
        await NotificationService.showWeatherAlert(
          'Интенсивные осадки',
          'Ожидается ${precip.toStringAsFixed(1)} мм осадков',
        );
      }
    } catch (e) {
      // Silence errors during alert check
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Text(
                'Weather Now',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Главная'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Прогноз'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ForecastScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выйти'),
              onTap: () {
                AuthService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
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

          final temp = (weather['temp'] as num).round();
          final wind = (weather['wind'] as num).round();
          final precip = weather['precipitation'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$temp°', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text('💨 Ветер: $wind м/с'),
                Text('🌧 Осадки: $precip мм'),
              ],
            ),
          );
        },
      ),
    );
  }
}

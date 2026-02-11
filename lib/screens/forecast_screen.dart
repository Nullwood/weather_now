import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  String _hour(DateTime time) => "${time.hour.toString().padLeft(2, '0')}:00";

  String _precipText(num mm, num prob) {
    final mmD = mm.toDouble();
    final probD = prob.toDouble();
    if (mmD == 0 && probD < 20) return '';
    if (mmD == 0) return '${probD.round()}%';
    return '${probD.round()}% • ${mmD.toStringAsFixed(1)} мм';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Прогноз')),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: WeatherService().fetchHourlyForecast(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки прогноза'));
          }

          final hours = snapshot.data!;

          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (var h in hours) {
            final dateStr = DateFormat('dd.MM.yyyy').format(h['time']);
            grouped.putIfAbsent(dateStr, () => []).add(h);
          }

          final List<Widget> sections = [];
          grouped.forEach((date, hourList) {
            sections.add(
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  date == DateFormat('dd.MM.yyyy').format(DateTime.now())
                      ? 'Сегодня'
                      : date,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );

            for (var h in hourList) {
              sections.add(
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(_hour(h['time'] as DateTime)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💨 ${(h['wind'] as num).round()} м/с'),
                      if (_precipText(
                        h['precipitation'],
                        h['probability'],
                      ).isNotEmpty)
                        Text(
                          '🌧 ${_precipText(h['precipitation'], h['probability'])}',
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${(h['temp'] as num).round()}°',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }
          });

          return ListView(children: sections);
        },
      ),
    );
  }
}

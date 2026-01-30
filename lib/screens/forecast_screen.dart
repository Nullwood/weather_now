import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  String _hour(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:00';

  String _precipText(double mm, double prob) {
    if (mm == 0 && prob < 20) return '';
    if (mm == 0) return '${prob.round()}%';
    return '${prob.round()}% • ${mm.toStringAsFixed(1)} мм';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Прогноз')),
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

          // Группировка по дате
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
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            );

            for (var h in hourList) {
              sections.add(
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(_hour(h['time'])),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💨 ${h['wind'].round()} м/с'),
                      if (_precipText(h['precipitation'], h['probability'])
                          .isNotEmpty)
                        Text('🌧 ${_precipText(h['precipitation'], h['probability'])}'),
                    ],
                  ),
                  trailing: Text(
                    '${h['temp'].round()}°',
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

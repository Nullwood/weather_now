import 'package:flutter/material.dart';
import '../services/weather_service.dart';


class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Прогноз')),
      body: FutureBuilder(
        future: WeatherService().fetchHourlyForecast(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final hours = snapshot.data!;

          return ListView.builder(
            itemCount: hours.length,
            itemBuilder: (context, index) {
              final hour = hours[index];
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('${hour['time']}'),
                trailing: Text('${hour['temp']}°C'),
              );
            },
          );
        },
      ),
    );
  }
}

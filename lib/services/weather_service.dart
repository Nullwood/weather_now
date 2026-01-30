import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/city_store.dart';

class WeatherService {
  String get url {
    final city = CityStore.currentCity;
    return 'https://api.open-meteo.com/v1/forecast'
        '?latitude=${city.lat}'
        '&longitude=${city.lon}'
        '&current=temperature_2m,wind_speed_10m,precipitation'
        '&hourly=temperature_2m,wind_speed_10m,precipitation,precipitation_probability'
        '&timezone=auto';
  }

  Future<Map<String, dynamic>> fetchCurrentWeather() async {
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final current = data['current'];

    return {
      'temp': current['temperature_2m'],
      'wind': current['wind_speed_10m'],
      'precipitation': current['precipitation'],
    };
  }

  Future<List<Map<String, dynamic>>> fetchHourlyForecast() async {
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final List times = data['hourly']['time'];
    final List temps = data['hourly']['temperature_2m'];
    final List winds = data['hourly']['wind_speed_10m'];
    final List precip = data['hourly']['precipitation'];
    final List prob = data['hourly']['precipitation_probability'];

    return List.generate(times.length, (i) {
      return {
        'time': DateTime.parse(times[i]),
        'temp': temps[i],
        'wind': winds[i],
        'precipitation': precip[i],
        'probability': prob[i],
      };
    });
  }
}

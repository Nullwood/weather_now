import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/city_store.dart';

class WeatherService {
  String get url {
    final city = CityStore.currentCity;
    return 'https://api.open-meteo.com/v1/forecast'
        '?latitude=${city.lat}'
        '&longitude=${city.lon}'
        '&current_weather=true'
        '&hourly=temperature_2m'
        '&timezone=auto';
  }

  Future<Map<String, dynamic>> fetchCurrentWeather() async {
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    return data['current_weather'];
  }

  Future<List<Map<String, dynamic>>> fetchHourlyForecast() async {
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final List times = data['hourly']['time'];
    final List temps = data['hourly']['temperature_2m'];

    return List.generate(times.length, (index) {
      return {
        'time': times[index],
        'temp': temps[index],
      };
    });
  }
}

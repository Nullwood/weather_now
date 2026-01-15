import 'package:flutter/material.dart';
import '../data/cities.dart';
import '../services/city_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор города')),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];

          return ListTile(
            title: Text(city.name),
            trailing: CityStore.currentCity.name == city.name
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              CityStore.currentCity = city;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Выбран город: ${city.name}')),
              );
            },
          );
        },
      ),
    );
  }
}

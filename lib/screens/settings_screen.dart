import 'package:flutter/material.dart';
import '../data/cities.dart';
import '../services/city_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор города')),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          final isSelected = CityStore.currentCity.name == city.name;

          return GestureDetector(
            onTap: () {
              setState(() {
                CityStore.currentCity = city;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Выбран город: ${city.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent.withOpacity(0.7) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                city.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

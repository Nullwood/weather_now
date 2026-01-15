class Weather {
  final String city;
  final double temp;
  final String description;

  Weather({
    required this.city,
    required this.temp,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      temp: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
    );
  }
}

import 'package:equatable/equatable.dart';

class CountrySummary extends Equatable {
  final String name;
  final String flagUrl;
  final int population;
  final String countryCode;

  const CountrySummary({
    required this.name,
    required this.flagUrl,
    required this.population,
    required this.countryCode,
  });

  @override
  List<Object> get props => [name, flagUrl, population, countryCode];
}

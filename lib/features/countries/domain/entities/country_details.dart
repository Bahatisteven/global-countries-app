import 'package:equatable/equatable.dart';

class CountryDetails extends Equatable {
  final String name;
  final String flagUrl;
  final int population;
  final List<String> capital;
  final String region;
  final String subregion;
  final double area;
  final List<String> timezones;
  final String countryCode;

  const CountryDetails({
    required this.name,
    required this.flagUrl,
    required this.population,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.area,
    required this.timezones,
    required this.countryCode,
  });

  @override
  List<Object> get props => [
        name,
        flagUrl,
        population,
        capital,
        region,
        subregion,
        area,
        timezones,
        countryCode,
      ];
}

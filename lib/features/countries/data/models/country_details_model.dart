import '../../domain/entities/country_details.dart';

class CountryDetailsModel extends CountryDetails {
  const CountryDetailsModel({
    required super.name,
    required super.flagUrl,
    required super.population,
    required super.capital,
    required super.region,
    required super.subregion,
    required super.area,
    required super.timezones,
    required super.countryCode,
  });

  factory CountryDetailsModel.fromJson(Map<String, dynamic> json) {
    return CountryDetailsModel(
      name: json['name']['common'] as String? ?? '',
      flagUrl: json['flags']['png'] as String? ?? '',
      population: json['population'] as int? ?? 0,
      capital: (json['capital'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      region: json['region'] as String? ?? '',
      subregion: json['subregion'] as String? ?? '',
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      timezones: (json['timezones'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      countryCode: json['cca2'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name},
      'flags': {'png': flagUrl},
      'population': population,
      'capital': capital,
      'region': region,
      'subregion': subregion,
      'area': area,
      'timezones': timezones,
      'cca2': countryCode,
    };
  }
}

import '../entities/country_summary.dart';

class CountrySummaryModel extends CountrySummary {
  const CountrySummaryModel({
    required super.name,
    required super.flagUrl,
    required super.population,
    required super.countryCode,
  });

  factory CountrySummaryModel.fromJson(Map<String, dynamic> json) {
    return CountrySummaryModel(
      name: json['name']['common'] as String? ?? '',
      flagUrl: json['flags']['png'] as String? ?? '',
      population: json['population'] as int? ?? 0,
      countryCode: json['cca2'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name},
      'flags': {'png': flagUrl},
      'population': population,
      'cca2': countryCode,
    };
  }
}

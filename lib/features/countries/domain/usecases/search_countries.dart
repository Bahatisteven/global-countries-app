import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/country_summary.dart';
import '../repositories/country_repository.dart';

class SearchCountries {
  final CountryRepository repository;

  SearchCountries(this.repository);

  Future<Either<Failure, List<CountrySummary>>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }
    return await repository.searchCountries(query);
  }
}

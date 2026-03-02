import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/country_summary.dart';
import '../repositories/country_repository.dart';

class GetAllCountries {
  final CountryRepository repository;

  GetAllCountries(this.repository);

  Future<Either<Failure, List<CountrySummary>>> call() async {
    return await repository.getAllCountries();
  }
}

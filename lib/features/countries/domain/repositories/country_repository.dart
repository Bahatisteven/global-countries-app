import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/country_details.dart';
import '../entities/country_summary.dart';

abstract class CountryRepository {
  Future<Either<Failure, List<CountrySummary>>> getAllCountries();
  Future<Either<Failure, List<CountrySummary>>> searchCountries(String query);
  Future<Either<Failure, CountryDetails>> getCountryDetails(String countryCode);
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/country_details.dart';
import '../repositories/country_repository.dart';

class GetCountryDetails {
  final CountryRepository repository;

  GetCountryDetails(this.repository);

  Future<Either<Failure, CountryDetails>> call(String countryCode) async {
    return await repository.getCountryDetails(countryCode);
  }
}

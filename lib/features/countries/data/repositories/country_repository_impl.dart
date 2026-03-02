import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/country_details.dart';
import '../../domain/entities/country_summary.dart';
import '../../domain/repositories/country_repository.dart';
import '../datasources/country_remote_datasource.dart';

class CountryRepositoryImpl implements CountryRepository {
  final CountryRemoteDatasource remoteDatasource;

  CountryRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<CountrySummary>>> getAllCountries() async {
    try {
      final countries = await remoteDatasource.getAllCountries();
      return Right(countries);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CountrySummary>>> searchCountries(
      String query) async {
    try {
      final countries = await remoteDatasource.searchCountries(query);
      return Right(countries);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CountryDetails>> getCountryDetails(
      String countryCode) async {
    try {
      final country = await remoteDatasource.getCountryDetails(countryCode);
      return Right(country);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

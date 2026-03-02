import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDatasource localDatasource;

  FavoritesRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<String>>> getFavorites() async {
    try {
      final favorites = await localDatasource.getFavorites();
      return Right(favorites);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(String countryCode) async {
    try {
      await localDatasource.addFavorite(countryCode);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String countryCode) async {
    try {
      await localDatasource.removeFavorite(countryCode);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String countryCode) async {
    try {
      final result = await localDatasource.isFavorite(countryCode);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}

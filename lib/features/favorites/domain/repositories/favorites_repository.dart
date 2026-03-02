import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<String>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(String countryCode);
  Future<Either<Failure, void>> removeFavorite(String countryCode);
  Future<Either<Failure, bool>> isFavorite(String countryCode);
}

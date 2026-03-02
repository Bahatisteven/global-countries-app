import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/favorites_repository.dart';

class RemoveFavorite {
  final FavoritesRepository repository;

  RemoveFavorite(this.repository);

  Future<Either<Failure, void>> call(String countryCode) async {
    return await repository.removeFavorite(countryCode);
  }
}

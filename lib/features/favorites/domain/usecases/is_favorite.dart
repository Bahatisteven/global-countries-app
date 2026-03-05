import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/favorites_repository.dart';

class IsFavorite {
  final FavoritesRepository repository;

  IsFavorite(this.repository);

  Future<Either<Failure, bool>> call(String countryCode) async {
    return await repository.isFavorite(countryCode);
  }
}

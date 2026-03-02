import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/favorites_repository.dart';

class AddFavorite {
  final FavoritesRepository repository;

  AddFavorite(this.repository);

  Future<Either<Failure, void>> call(String countryCode) async {
    return await repository.addFavorite(countryCode);
  }
}

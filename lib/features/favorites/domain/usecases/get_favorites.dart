import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository repository;

  GetFavorites(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getFavorites();
  }
}

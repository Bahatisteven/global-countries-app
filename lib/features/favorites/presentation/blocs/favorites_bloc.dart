import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/is_favorite.dart';
import '../../domain/usecases/remove_favorite.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites getFavorites;
  final AddFavorite addFavorite;
  final RemoveFavorite removeFavorite;
  final IsFavorite isFavorite;

  FavoritesBloc({
    required this.getFavorites,
    required this.addFavorite,
    required this.removeFavorite,
    required this.isFavorite,
  }) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CheckFavoriteEvent>(_onCheckFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    final result = await getFavorites();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) => emit(FavoritesLoaded(favorites)),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final checkResult = await isFavorite(event.countryCode);
    await checkResult.fold(
      (failure) async => emit(FavoritesError(failure.message)),
      (isCurrentlyFavorite) async {
        if (isCurrentlyFavorite) {
          final result = await removeFavorite(event.countryCode);
          result.fold(
            (failure) => emit(FavoritesError(failure.message)),
            (_) => add(LoadFavoritesEvent()),
          );
        } else {
          final result = await addFavorite(event.countryCode);
          result.fold(
            (failure) => emit(FavoritesError(failure.message)),
            (_) => add(LoadFavoritesEvent()),
          );
        }
      },
    );
  }

  Future<void> _onCheckFavorite(
    CheckFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await isFavorite(event.countryCode);
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (isFav) => emit(FavoriteChecked(isFav, event.countryCode)),
    );
  }
}

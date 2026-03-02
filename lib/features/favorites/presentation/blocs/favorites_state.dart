part of 'favorites_bloc.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<String> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}

class FavoriteChecked extends FavoritesState {
  final bool isFavorite;
  final String countryCode;

  const FavoriteChecked(this.isFavorite, this.countryCode);

  @override
  List<Object> get props => [isFavorite, countryCode];
}

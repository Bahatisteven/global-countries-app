part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String countryCode;

  const ToggleFavoriteEvent(this.countryCode);

  @override
  List<Object> get props => [countryCode];
}

class CheckFavoriteEvent extends FavoritesEvent {
  final String countryCode;

  const CheckFavoriteEvent(this.countryCode);

  @override
  List<Object> get props => [countryCode];
}

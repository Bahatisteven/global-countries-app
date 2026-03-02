part of 'country_detail_bloc.dart';

abstract class CountryDetailState extends Equatable {
  const CountryDetailState();

  @override
  List<Object> get props => [];
}

class CountryDetailInitial extends CountryDetailState {}

class CountryDetailLoading extends CountryDetailState {}

class CountryDetailLoaded extends CountryDetailState {
  final CountryDetails country;

  const CountryDetailLoaded(this.country);

  @override
  List<Object> get props => [country];
}

class CountryDetailError extends CountryDetailState {
  final String message;

  const CountryDetailError(this.message);

  @override
  List<Object> get props => [message];
}

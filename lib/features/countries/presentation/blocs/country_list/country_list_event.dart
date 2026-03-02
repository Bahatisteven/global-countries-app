part of 'country_list_bloc.dart';

abstract class CountryListEvent extends Equatable {
  const CountryListEvent();

  @override
  List<Object> get props => [];
}

class LoadCountriesEvent extends CountryListEvent {}

class SearchCountriesEvent extends CountryListEvent {
  final String query;

  const SearchCountriesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class RefreshCountriesEvent extends CountryListEvent {}

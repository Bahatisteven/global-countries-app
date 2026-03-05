part of 'country_detail_bloc.dart';

abstract class CountryDetailEvent extends Equatable {
  const CountryDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadCountryDetailEvent extends CountryDetailEvent {
  final String countryCode;

  const LoadCountryDetailEvent(this.countryCode);

  @override
  List<Object> get props => [countryCode];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/country_summary.dart';
import '../../../domain/usecases/get_all_countries.dart';
import '../../../domain/usecases/search_countries.dart';

part 'country_list_event.dart';
part 'country_list_state.dart';

class CountryListBloc extends Bloc<CountryListEvent, CountryListState> {
  final GetAllCountries getAllCountries;
  final SearchCountries searchCountries;

  CountryListBloc({
    required this.getAllCountries,
    required this.searchCountries,
  }) : super(CountryListInitial()) {
    on<LoadCountriesEvent>(_onLoadCountries);
    on<SearchCountriesEvent>(_onSearchCountries);
    on<RefreshCountriesEvent>(_onRefreshCountries);
  }

  Future<void> _onLoadCountries(
    LoadCountriesEvent event,
    Emitter<CountryListState> emit,
  ) async {
    emit(CountryListLoading());
    final result = await getAllCountries();
    result.fold(
      (failure) => emit(CountryListError(failure.message)),
      (countries) => emit(CountryListLoaded(countries)),
    );
  }

  Future<void> _onSearchCountries(
    SearchCountriesEvent event,
    Emitter<CountryListState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(LoadCountriesEvent());
      return;
    }

    emit(CountryListSearching());
    final result = await searchCountries(event.query);
    result.fold(
      (failure) => emit(CountryListError(failure.message)),
      (countries) => emit(CountryListSearchResults(countries, event.query)),
    );
  }

  Future<void> _onRefreshCountries(
    RefreshCountriesEvent event,
    Emitter<CountryListState> emit,
  ) async {
    final result = await getAllCountries();
    result.fold(
      (failure) => emit(CountryListError(failure.message)),
      (countries) => emit(CountryListLoaded(countries)),
    );
  }
}

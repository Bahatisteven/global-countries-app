import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/country_details.dart';
import '../../../domain/usecases/get_country_details.dart';

part 'country_detail_event.dart';
part 'country_detail_state.dart';

class CountryDetailBloc extends Bloc<CountryDetailEvent, CountryDetailState> {
  final GetCountryDetails getCountryDetails;

  CountryDetailBloc({required this.getCountryDetails})
      : super(CountryDetailInitial()) {
    on<LoadCountryDetailEvent>(_onLoadCountryDetail);
  }

  Future<void> _onLoadCountryDetail(
    LoadCountryDetailEvent event,
    Emitter<CountryDetailState> emit,
  ) async {
    emit(CountryDetailLoading());
    final result = await getCountryDetails(event.countryCode);
    result.fold(
      (failure) => emit(CountryDetailError(failure.message)),
      (country) => emit(CountryDetailLoaded(country)),
    );
  }
}

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/country_details_model.dart';
import '../models/country_summary_model.dart';

abstract class CountryRemoteDatasource {
  Future<List<CountrySummaryModel>> getAllCountries();
  Future<List<CountrySummaryModel>> searchCountries(String query);
  Future<CountryDetailsModel> getCountryDetails(String countryCode);
}

class CountryRemoteDatasourceImpl implements CountryRemoteDatasource {
  final Dio dio;

  CountryRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<CountrySummaryModel>> getAllCountries() async {
    try {
      final response = await dio.get(
        ApiConstants.allCountries,
        queryParameters: {'fields': ApiConstants.listFields},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw NetworkException('Connection timeout - please check your internet');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) {
          return [];
        }
        return data.map((json) => CountrySummaryModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load countries: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout - please check your internet');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection - please connect to WiFi or mobile data');
      } else if (e.response != null) {
        throw ServerException('Server error: ${e.response?.statusCode}');
      } else {
        throw ServerException(e.message ?? 'Unknown server error');
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load countries: ${e.toString()}');
    }
  }

  @override
  Future<List<CountrySummaryModel>> searchCountries(String query) async {
    try {
      final response = await dio.get(
        '${ApiConstants.searchCountries}/$query',
        queryParameters: {'fields': ApiConstants.listFields},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CountrySummaryModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to search countries');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No countries found
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(e.message ?? 'Server error');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CountryDetailsModel> getCountryDetails(String countryCode) async {
    try {
      final response = await dio.get(
        '${ApiConstants.countryByCode}/$countryCode',
        queryParameters: {'fields': ApiConstants.detailFields},
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List && data.isNotEmpty) {
          return CountryDetailsModel.fromJson(data[0]);
        } else if (data is Map<String, dynamic>) {
          return CountryDetailsModel.fromJson(data);
        } else {
          throw ServerException('Country not found');
        }
      } else {
        throw ServerException('Failed to load country details');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(e.message ?? 'Server error');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

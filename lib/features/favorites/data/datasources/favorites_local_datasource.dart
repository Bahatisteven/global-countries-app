import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

abstract class FavoritesLocalDatasource {
  Future<List<String>> getFavorites();
  Future<void> addFavorite(String countryCode);
  Future<void> removeFavorite(String countryCode);
  Future<bool> isFavorite(String countryCode);
}

class FavoritesLocalDatasourceImpl implements FavoritesLocalDatasource {
  static const String _boxName = 'favorites';
  static const String _key = 'favorite_countries';

  Box get _box => Hive.box(_boxName);

  @override
  Future<List<String>> getFavorites() async {
    try {
      final favorites = _box.get(_key, defaultValue: <String>[]);
      return List<String>.from(favorites);
    } catch (e) {
      throw CacheException('Failed to load favorites');
    }
  }

  @override
  Future<void> addFavorite(String countryCode) async {
    try {
      final favorites = await getFavorites();
      if (!favorites.contains(countryCode)) {
        favorites.add(countryCode);
        await _box.put(_key, favorites);
      }
    } catch (e) {
      throw CacheException('Failed to add favorite');
    }
  }

  @override
  Future<void> removeFavorite(String countryCode) async {
    try {
      final favorites = await getFavorites();
      favorites.remove(countryCode);
      await _box.put(_key, favorites);
    } catch (e) {
      throw CacheException('Failed to remove favorite');
    }
  }

  @override
  Future<bool> isFavorite(String countryCode) async {
    try {
      final favorites = await getFavorites();
      return favorites.contains(countryCode);
    } catch (e) {
      throw CacheException('Failed to check favorite');
    }
  }
}

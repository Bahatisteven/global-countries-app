import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection_container.dart';
import '../blocs/favorites_bloc.dart';
import '../../../countries/presentation/pages/country_detail_page.dart';
import '../../../countries/presentation/blocs/country_detail/country_detail_bloc.dart';

class FavoritesPage extends StatelessWidget {
  final bool showAppBar;
  
  const FavoritesPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesBloc>()..add(LoadFavoritesEvent()),
      child: Scaffold(
        appBar: showAppBar ? AppBar(
          title: const Text('Favorites'),
        ) : null,
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add countries to your favorites',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final countryCode = state.favorites[index];
                  return _FavoriteCountryCard(
                    countryCode: countryCode,
                  );
                },
              );
            } else if (state is FavoritesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FavoritesBloc>().add(LoadFavoritesEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _FavoriteCountryCard extends StatelessWidget {
  final String countryCode;

  const _FavoriteCountryCard({
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CountryDetailBloc>()
        ..add(LoadCountryDetailEvent(countryCode)),
      child: BlocBuilder<CountryDetailBloc, CountryDetailState>(
        builder: (context, state) {
          if (state is CountryDetailLoaded) {
            final country = state.country;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: country.flagUrl,
                    width: 60,
                    height: 45,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 45,
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 45,
                      color: Colors.grey[300],
                      child: const Icon(Icons.flag, size: 24),
                    ),
                  ),
                ),
                title: Text(
                  country.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  country.capital.isNotEmpty
                      ? country.capital.join(', ')
                      : 'No capital',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        context.read<FavoritesBloc>().add(
                              ToggleFavoriteEvent(countryCode),
                            );
                      },
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CountryDetailPage(
                        countryCode: countryCode,
                        countryName: country.name,
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is CountryDetailError) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 45,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
                title: Text(countryCode),
                subtitle: const Text('Failed to load'),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    context.read<FavoritesBloc>().add(
                          ToggleFavoriteEvent(countryCode),
                        );
                  },
                ),
              ),
            );
          }
          // Loading state
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 60,
                height: 45,
                color: Colors.grey[300],
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              title: Text(countryCode),
              subtitle: const Text('Loading...'),
            ),
          );
        },
      ),
    );
  }
}

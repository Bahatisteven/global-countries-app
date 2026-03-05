import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../blocs/country_detail/country_detail_bloc.dart';
import '../../../favorites/presentation/blocs/favorites_bloc.dart';

class CountryDetailPage extends StatelessWidget {
  final String countryCode;
  final String countryName;

  const CountryDetailPage({
    super.key,
    required this.countryCode,
    required this.countryName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<CountryDetailBloc>()
            ..add(LoadCountryDetailEvent(countryCode)),
        ),
        BlocProvider(
          create: (_) => sl<FavoritesBloc>()
            ..add(CheckFavoriteEvent(countryCode)),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(countryName),
          actions: [
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                bool isFavorite = false;
                if (state is FavoriteChecked) {
                  isFavorite = state.isFavorite;
                } else if (state is FavoritesLoaded) {
                  isFavorite = state.favorites.contains(countryCode);
                }

                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    context.read<FavoritesBloc>().add(
                          ToggleFavoriteEvent(countryCode),
                        );
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<CountryDetailBloc, CountryDetailState>(
          builder: (context, state) {
            if (state is CountryDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CountryDetailLoaded) {
              final country = state.country;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                  ),
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getPagePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Hero(
                            tag: 'flag-$countryCode',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                country.flagUrl,
                                height: ResponsiveHelper.isMobile(context) ? 200 : 300,
                                fit: BoxFit.cover,
                                errorBuilder: (context, url, error) => Container(
                                  height: ResponsiveHelper.isMobile(context) ? 200 : 300,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.flag, size: 64),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          country.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        _buildResponsiveInfoCards(context, country),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is CountryDetailError) {
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
                        context.read<CountryDetailBloc>().add(
                              LoadCountryDetailEvent(countryCode),
                            );
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

  Widget _buildResponsiveInfoCards(BuildContext context, country) {
    final infoCards = [
      _InfoCard(
        icon: Icons.people,
        title: 'Population',
        value: country.population.toFormattedString(),
      ),
      _InfoCard(
        icon: Icons.location_city,
        title: 'Capital',
        value: country.capital.isEmpty ? 'N/A' : country.capital.join(', '),
      ),
      _InfoCard(
        icon: Icons.public,
        title: 'Region',
        value: country.region,
      ),
      _InfoCard(
        icon: Icons.map,
        title: 'Subregion',
        value: country.subregion.isEmpty ? 'N/A' : country.subregion,
      ),
      _InfoCard(
        icon: Icons.square_foot,
        title: 'Area',
        value: '${country.area.toFormattedString()} km²',
      ),
      _InfoCard(
        icon: Icons.access_time,
        title: 'Timezones',
        value: country.timezones.join(', '),
      ),
    ];

    if (ResponsiveHelper.isMobile(context)) {
      return Column(children: infoCards);
    }

    // For tablet and desktop, show cards in a 2-column grid
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: infoCards.map((card) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 200) / 2,
          child: card,
        );
      }).toList(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

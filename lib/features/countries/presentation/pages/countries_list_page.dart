import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/country_summary.dart';
import '../blocs/country_list/country_list_bloc.dart';
import '../widgets/country_card.dart';
import '../widgets/loading_shimmer.dart';
import 'country_detail_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';

class CountriesListPage extends StatefulWidget {
  final bool showAppBar;
  
  const CountriesListPage({super.key, this.showAppBar = true});

  @override
  State<CountriesListPage> createState() => _CountriesListPageState();
}

class _CountriesListPageState extends State<CountriesListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CountrySummary> _allCountries = [];
  List<CountrySummary> _displayedCountries = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        setState(() {
          _displayedCountries = _allCountries;
        });
      } else {
        setState(() {
          _displayedCountries = _allCountries
              .where((country) => country.name.toLowerCase().contains(query))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CountryListBloc>()..add(LoadCountriesEvent()),
      child: Scaffold(
        appBar: widget.showAppBar ? AppBar(
          title: const Text('Countries'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FavoritesPage(),
                  ),
                );
              },
            ),
          ],
        ) : null,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search countries...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<CountryListBloc, CountryListState>(
                builder: (context, state) {
                  if (state is CountryListLoading) {
                    return const LoadingShimmer();
                  } else if (state is CountryListLoaded) {
                    _allCountries = state.countries;
                    if (_displayedCountries.isEmpty && _searchController.text.isEmpty) {
                      _displayedCountries = _allCountries;
                    }
                    
                    if (_displayedCountries.isEmpty) {
                      return const Center(
                        child: Text('No countries found'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<CountryListBloc>().add(RefreshCountriesEvent());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _displayedCountries.length,
                        itemBuilder: (context, index) {
                          final country = _displayedCountries[index];
                          return CountryCard(
                            country: country,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CountryDetailPage(
                                    countryCode: country.countryCode,
                                    countryName: country.name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  } else if (state is CountryListError) {
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
                              context.read<CountryListBloc>().add(LoadCountriesEvent());
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
          ],
        ),
      ),
    );
  }
}

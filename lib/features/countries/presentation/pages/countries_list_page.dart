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

enum SortOption { nameAsc, nameDesc, populationAsc, populationDesc }

class _CountriesListPageState extends State<CountriesListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CountrySummary> _allCountries = [];
  List<CountrySummary> _displayedCountries = [];
  Timer? _debounceTimer;
  SortOption _currentSort = SortOption.nameAsc;

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
          _displayedCountries = List.from(_allCountries);
          _applySorting();
        });
      } else {
        setState(() {
          _displayedCountries = _allCountries
              .where((country) => country.name.toLowerCase().contains(query))
              .toList();
          _applySorting();
        });
      }
    });
  }

  void _applySorting() {
    switch (_currentSort) {
      case SortOption.nameAsc:
        _displayedCountries.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        _displayedCountries.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.populationAsc:
        _displayedCountries.sort((a, b) => a.population.compareTo(b.population));
        break;
      case SortOption.populationDesc:
        _displayedCountries.sort((a, b) => b.population.compareTo(a.population));
        break;
    }
  }

  void _changeSortOption(SortOption? option) {
    if (option != null && option != _currentSort) {
      setState(() {
        _currentSort = option;
        _applySorting();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CountryListBloc>()..add(LoadCountriesEvent()),
      child: Scaffold(
        appBar: widget.showAppBar ? AppBar(
          title: const Text('Countries'),
          actions: [
            PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort countries',
              onSelected: _changeSortOption,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: SortOption.nameAsc,
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha),
                      SizedBox(width: 8),
                      Text('Name (A-Z)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: SortOption.nameDesc,
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha),
                      SizedBox(width: 8),
                      Text('Name (Z-A)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: SortOption.populationAsc,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward),
                      SizedBox(width: 8),
                      Text('Population (Low-High)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: SortOption.populationDesc,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward),
                      SizedBox(width: 8),
                      Text('Population (High-Low)'),
                    ],
                  ),
                ),
              ],
            ),
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
                      _displayedCountries = List.from(_allCountries);
                      _applySorting();
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

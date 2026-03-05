import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  runApp(const CountriesApp());
}

class CountriesApp extends StatelessWidget {
  const CountriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Countries' : 'Favorites'),
      ),
      body: _selectedIndex == 0 ? const CountriesPage() : const FavoritesPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }
}

class CountriesPage extends StatefulWidget {
  const CountriesPage({super.key});

  @override
  State<CountriesPage> createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> {
  List<dynamic> countries = [];
  List<dynamic> filteredCountries = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String selectedRegion = 'All';

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      
      final response = await dio.get(
        'https://restcountries.com/v3.1/all?fields=name,flags,population,cca2,region'
      ).timeout(const Duration(seconds: 6));
      
      if (response.statusCode == 200) {
        setState(() {
          countries = response.data;
          filteredCountries = countries;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load: $e';
        isLoading = false;
      });
    }
  }

  void filterCountries() {
    setState(() {
      filteredCountries = countries.where((c) {
        final name = c['name']['common'].toString().toLowerCase();
        final region = c['region'] ?? '';
        final matchesSearch = name.contains(searchQuery.toLowerCase());
        final matchesRegion = selectedRegion == 'All' || region == selectedRegion;
        return matchesSearch && matchesRegion;
      }).toList();
    });
  }

  Future<void> toggleFavorite(String countryCode) async {
    final box = Hive.box('favorites');
    if (box.containsKey(countryCode)) {
      await box.delete(countryCode);
    } else {
      await box.put(countryCode, DateTime.now().toString());
    }
    setState(() {});
  }

  bool isFavorite(String countryCode) {
    return Hive.box('favorites').containsKey(countryCode);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading countries...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: loadCountries,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search countries...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              searchQuery = value;
              filterCountries();
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['All', 'Africa', 'Americas', 'Asia', 'Europe', 'Oceania']
                .map((region) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(region),
                        selected: selectedRegion == region,
                        onSelected: (selected) {
                          setState(() => selectedRegion = region);
                          filterCountries();
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadCountries,
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                final country = filteredCountries[index];
                final name = country['name']['common'];
                final population = country['population'];
                final flag = country['flags']?['png'] ?? '';
                final code = country['cca2'];

                return ListTile(
                  leading: flag.isNotEmpty
                      ? Image.network(flag, width: 50, errorBuilder: (_, __, ___) => 
                          const Icon(Icons.flag))
                      : const Icon(Icons.flag),
                  title: Text(name),
                  subtitle: Text('Population: ${population.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                    (m) => '${m[1]},'
                  )}'),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite(code) ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () => toggleFavorite(code),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CountryDetailPage(
                          countryCode: code,
                          countryName: name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('favorites');
    final favorites = box.keys.toList();

    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64),
            SizedBox(height: 16),
            Text('No favorites yet'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final code = favorites[index];
        return ListTile(
          title: Text('Country: $code'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await box.delete(code);
            },
          ),
        );
      },
    );
  }
}

class CountryDetailPage extends StatefulWidget {
  final String countryCode;
  final String countryName;

  const CountryDetailPage({
    super.key,
    required this.countryCode,
    required this.countryName,
  });

  @override
  State<CountryDetailPage> createState() => _CountryDetailPageState();
}

class _CountryDetailPageState extends State<CountryDetailPage> {
  Map<String, dynamic>? countryData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://restcountries.com/v3.1/alpha/${widget.countryCode}'
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        setState(() {
          // API returns single object, not array
          countryData = response.data is List ? response.data[0] : response.data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load details';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.countryName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (countryData?['flags']?['png'] != null)
                        Center(
                          child: Image.network(
                            countryData!['flags']['png'],
                            height: 200,
                          ),
                        ),
                      const SizedBox(height: 24),
                      _buildInfoRow('Official Name', 
                        countryData?['name']?['official'] ?? 'N/A'),
                      _buildInfoRow('Capital', 
                        countryData?['capital']?.join(', ') ?? 'N/A'),
                      _buildInfoRow('Region', 
                        countryData?['region'] ?? 'N/A'),
                      _buildInfoRow('Subregion', 
                        countryData?['subregion'] ?? 'N/A'),
                      _buildInfoRow('Population', 
                        countryData?['population']?.toString() ?? 'N/A'),
                      _buildInfoRow('Area', 
                        '${countryData?['area'] ?? 'N/A'} km²'),
                      _buildInfoRow('Timezones', 
                        countryData?['timezones']?.join(', ') ?? 'N/A'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

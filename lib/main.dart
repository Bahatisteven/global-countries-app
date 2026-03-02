import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/countries/presentation/pages/countries_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countries App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const CountriesListPage(),
    );
  }
}

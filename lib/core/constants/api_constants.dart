class ApiConstants {
  static const String baseUrl = 'https://restcountries.com/v3.1';
  
  // Endpoints
  static const String allCountries = '/all';
  static const String searchCountries = '/name';
  static const String countryByCode = '/alpha';
  
  // Fields for list view (minimal data)
  static const String listFields = 'name,flags,population,cca2';
  
  // Fields for detail view (full data)
  static const String detailFields = 'name,flags,population,capital,region,subregion,area,timezones,cca2';
}

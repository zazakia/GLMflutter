class AppConstants {
  // App info
  static const String appName = 'Job Order Management';
  static const String appVersion = '1.0.0';
  
  // Default currency
  static const String defaultCurrency = 'PHP';
  static const String defaultCurrencySymbol = '₱';
  
  // Default locale
  static const String defaultLocale = 'en_PH';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Image upload limits
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxImageDimension = 1600;
  static const int imageQuality = 70;
  
  // Service report reference number format
  static const String serviceReportNumberFormat = 'SR-YYYYMM-####';
  
  // VAT rate (Philippines)
  static const double defaultVatRate = 0.12; // 12%
}
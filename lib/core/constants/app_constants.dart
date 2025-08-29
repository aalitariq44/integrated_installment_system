class AppConstants {
  // App Information
  static const String appName = 'نظام إدارة الأقساط';
  static const String appVersion = '1.0.0';
  
  // Date Formats
  static const String dateFormat = 'yyyy/MM/dd';
  static const String dateTimeFormat = 'yyyy/MM/dd HH:mm';
  static const String displayDateFormat = 'dd/MM/yyyy';
  
  // Currency
  static const String currencySymbol = 'ريال';
  static const String currencyCode = 'SAR';
  
  // Defaults
  static const int defaultPaymentInterval = 30; // days
  static const String defaultPassword = '123456';
  
  // Receipt Settings
  static const String receiptPrefix = 'REC';
  static const int receiptNumberLength = 6;
  
  // Backup Settings
  static const String backupFileName = 'installments_backup.db';
  static const String backupBucket = 'installments-backups';
  
  // Database
  static const String databaseName = 'installments.db';
  static const int databaseVersion = 1;
  
  // Supabase (will be configured in env)
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Pagination
  static const int pageSize = 20;
  
  // Validation
  static const int maxNameLength = 100;
  static const int maxNotesLength = 500;
  static const int maxPhoneLength = 15;
  static const int minPasswordLength = 6;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const int shortAnimationDuration = 300;
  static const int mediumAnimationDuration = 500;
  static const int longAnimationDuration = 800;
}

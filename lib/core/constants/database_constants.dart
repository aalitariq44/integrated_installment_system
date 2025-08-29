class DatabaseConstants {
  // Database Information
  static const String databaseName = 'installments.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String settingsTable = 'settings';
  static const String customersTable = 'customers';
  static const String productsTable = 'products';
  static const String paymentsTable = 'payments';

  // Settings Table Columns
  static const String settingsId = 'id';
  static const String settingsAppPassword = 'app_password';
  static const String settingsBusinessName = 'business_name';
  static const String settingsOwnerName = 'owner_name';
  static const String settingsPhone = 'phone';
  static const String settingsCreatedDate = 'created_date';
  static const String settingsUpdatedDate = 'updated_date';

  // Customers Table Columns
  static const String customersId = 'customer_id';
  static const String customersName = 'customer_name';
  static const String customersPhone = 'phone_number';
  static const String customersAddress = 'address';
  static const String customersNotes = 'notes';
  static const String customersCreatedDate = 'created_date';
  static const String customersUpdatedDate = 'updated_date';

  // Products Table Columns
  static const String productsId = 'product_id';
  static const String productsCustomerId = 'customer_id';
  static const String productsName = 'product_name';
  static const String productsDetails = 'details';
  static const String productsOriginalPrice = 'original_price';
  static const String productsFinalPrice = 'final_price';
  static const String productsPaymentInterval = 'payment_interval_days';
  static const String productsSaleDate = 'sale_date';
  static const String productsNotes = 'notes';
  static const String productsTotalPaid = 'total_paid';
  static const String productsRemainingAmount = 'remaining_amount';
  static const String productsIsCompleted = 'is_completed';
  static const String productsCreatedDate = 'created_date';
  static const String productsUpdatedDate = 'updated_date';

  // Payments Table Columns
  static const String paymentsId = 'payment_id';
  static const String paymentsProductId = 'product_id';
  static const String paymentsCustomerId = 'customer_id';
  static const String paymentsAmount = 'payment_amount';
  static const String paymentsDate = 'payment_date';
  static const String paymentsNextDueDate = 'next_due_date';
  static const String paymentsNotes = 'notes';
  static const String paymentsReceiptNumber = 'receipt_number';
  static const String paymentsCreatedDate = 'created_date';

  // SQL Queries
  static const String createSettingsTable =
      '''
    CREATE TABLE $settingsTable (
      $settingsId INTEGER PRIMARY KEY,
      $settingsAppPassword TEXT NOT NULL,
      $settingsBusinessName TEXT,
      $settingsOwnerName TEXT,
      $settingsPhone TEXT,
      $settingsCreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
      $settingsUpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  static const String createCustomersTable =
      '''
    CREATE TABLE $customersTable (
      $customersId INTEGER PRIMARY KEY AUTOINCREMENT,
      $customersName TEXT NOT NULL,
      $customersPhone TEXT,
      $customersAddress TEXT,
      $customersNotes TEXT,
      $customersCreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
      $customersUpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  static const String createProductsTable =
      '''
    CREATE TABLE $productsTable (
      $productsId INTEGER PRIMARY KEY AUTOINCREMENT,
      $productsCustomerId INTEGER NOT NULL,
      $productsName TEXT NOT NULL,
      $productsDetails TEXT,
      $productsOriginalPrice REAL NOT NULL,
      $productsFinalPrice REAL NOT NULL,
      $productsPaymentInterval INTEGER NOT NULL,
      $productsSaleDate DATETIME DEFAULT CURRENT_TIMESTAMP,
      $productsNotes TEXT,
      $productsTotalPaid REAL DEFAULT 0,
      $productsRemainingAmount REAL,
      $productsIsCompleted BOOLEAN DEFAULT FALSE,
      $productsCreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
      $productsUpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY ($productsCustomerId) REFERENCES $customersTable ($customersId) ON DELETE CASCADE
    )
  ''';

  static const String createPaymentsTable =
      '''
    CREATE TABLE $paymentsTable (
      $paymentsId INTEGER PRIMARY KEY AUTOINCREMENT,
      $paymentsProductId INTEGER NOT NULL,
      $paymentsCustomerId INTEGER NOT NULL,
      $paymentsAmount REAL NOT NULL,
      $paymentsDate DATETIME DEFAULT CURRENT_TIMESTAMP,
      $paymentsNextDueDate DATETIME,
      $paymentsNotes TEXT,
      $paymentsReceiptNumber TEXT UNIQUE,
      $paymentsCreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY ($paymentsProductId) REFERENCES $productsTable ($productsId) ON DELETE CASCADE,
      FOREIGN KEY ($paymentsCustomerId) REFERENCES $customersTable ($customersId) ON DELETE CASCADE
    )
  ''';

  // Indexes
  static const String createIndexes =
      '''
    CREATE INDEX idx_products_customer_id ON $productsTable ($productsCustomerId);
    CREATE INDEX idx_payments_product_id ON $paymentsTable ($paymentsProductId);
    CREATE INDEX idx_payments_customer_id ON $paymentsTable ($paymentsCustomerId);
    CREATE INDEX idx_payments_date ON $paymentsTable ($paymentsDate);
    CREATE INDEX idx_products_sale_date ON $productsTable ($productsSaleDate);
  ''';
}

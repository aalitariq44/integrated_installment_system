class AppRoutes {
  // Authentication routes
  static const String splash = '/';
  static const String login = '/login';
  static const String setupPassword = '/setup-password'; // New route

  // Main navigation routes
  static const String home = '/home';
  static const String customers = '/customers';
  static const String statistics = '/statistics';
  static const String settings = '/settings';

  // Customer routes
  static const String customerDetails = '/customer-details';
  static const String addEditCustomer = '/add-edit-customer';

  // Product routes
  static const String productDetails = '/product-details';
  static const String addEditProduct = '/add-edit-product';

  // Payment routes
  static const String addPayment = '/add-payment';
  static const String paymentReceipt = '/payment-receipt';

  // Utility routes
  static const String backup = '/backup';
  static const String about = '/about';

  // Route parameters
  static const String customerIdParam = 'customerId';
  static const String productIdParam = 'productId';
  static const String paymentIdParam = 'paymentId';
  static const String isEditParam = 'isEdit';
}

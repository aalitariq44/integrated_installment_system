import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/customers/presentation/pages/customer_details_page.dart';
import '../../features/customers/presentation/pages/add_edit_customer_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/products/presentation/pages/add_edit_product_page.dart';
import '../../features/payments/presentation/pages/add_payment_page.dart';
import '../../features/payments/presentation/pages/payment_receipt_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRoutes.home:
      case AppRoutes.customers:
        return MaterialPageRoute(
          builder: (_) => const CustomersPage(),
          settings: settings,
        );

      case AppRoutes.customerDetails:
        final customerId = settings.arguments as int?;
        if (customerId == null) {
          return _errorRoute('معرف العميل مطلوب');
        }
        return MaterialPageRoute(
          builder: (_) => CustomerDetailsPage(customerId: customerId),
          settings: settings,
        );

      case AppRoutes.addEditCustomer:
        final Map<String, dynamic>? arguments =
            settings.arguments as Map<String, dynamic>?;
        final customerId = arguments?['customerId'] as int?;
        final isEdit = arguments?['isEdit'] as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) =>
              AddEditCustomerPage(customerId: customerId, isEdit: isEdit),
          settings: settings,
        );

      case AppRoutes.productDetails:
        final productId = settings.arguments as int?;
        if (productId == null) {
          return _errorRoute('معرف المنتج مطلوب');
        }
        return MaterialPageRoute(
          builder: (_) => ProductDetailsPage(productId: productId),
          settings: settings,
        );

      case AppRoutes.addEditProduct:
        final Map<String, dynamic>? arguments =
            settings.arguments as Map<String, dynamic>?;
        final customerId = arguments?['customerId'] as int?;
        final productId = arguments?['productId'] as int?;
        final isEdit = arguments?['isEdit'] as bool? ?? false;

        if (!isEdit && customerId == null) {
          return _errorRoute('معرف العميل مطلوب لإضافة منتج جديد');
        }

        return MaterialPageRoute(
          builder: (_) => AddEditProductPage(
            customerId: customerId,
            productId: productId,
            isEdit: isEdit,
          ),
          settings: settings,
        );

      case AppRoutes.addPayment:
        final productId = args?['productId'] as int?;
        final customerId = args?['customerId'] as int?;
        if (productId == null || customerId == null) {
          return _errorRoute('معرف المنتج والعميل مطلوبان');
        }
        return MaterialPageRoute(
          builder: (_) =>
              AddPaymentPage(productId: productId, customerId: customerId),
          settings: settings,
        );

      case AppRoutes.paymentReceipt:
        final receiptNumber = args?['receiptNumber'] as String?;
        final paymentData = args?['paymentData'] as Map<String, dynamic>?;
        final productData = args?['productData'] as Map<String, dynamic>?;
        final customerData = args?['customerData'] as Map<String, dynamic>?;

        if (receiptNumber == null || paymentData == null) {
          return _errorRoute('بيانات الإيصال مطلوبة');
        }

        return MaterialPageRoute(
          builder: (_) => PaymentReceiptPage(
            receiptNumber: receiptNumber,
            paymentData: paymentData,
            productData: productData,
            customerData: customerData,
          ),
          settings: settings,
        );

      case AppRoutes.statistics:
        return MaterialPageRoute(
          builder: (_) => const StatisticsPage(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );

      default:
        return _errorRoute('الصفحة غير موجودة');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animation builders for custom transitions
  static Route<T> fadeTransition<T extends Object?>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Route<T> slideTransition<T extends Object?>(
    Widget page,
    RouteSettings settings, {
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  static Route<T> scaleTransition<T extends Object?>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.ease;

        final tween = Tween(begin: 0.0, end: 1.0);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return ScaleTransition(
          scale: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}

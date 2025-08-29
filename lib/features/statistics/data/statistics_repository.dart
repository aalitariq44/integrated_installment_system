import '../../../core/database/database_helper.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/utils/date_utils.dart';

class StatisticsRepository {
  final DatabaseHelper _databaseHelper;

  StatisticsRepository({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  // Get overall statistics
  Future<Map<String, dynamic>> getOverallStatistics() async {
    try {
      final sql = '''
        SELECT 
          (SELECT COUNT(*) FROM ${DatabaseConstants.customersTable}) as total_customers,
          (SELECT COUNT(*) FROM ${DatabaseConstants.productsTable}) as total_products,
          (SELECT COUNT(*) FROM ${DatabaseConstants.productsTable} WHERE ${DatabaseConstants.productsIsCompleted} = 1) as completed_products,
          (SELECT COUNT(*) FROM ${DatabaseConstants.productsTable} WHERE ${DatabaseConstants.productsIsCompleted} = 0) as active_products,
          (SELECT COUNT(*) FROM ${DatabaseConstants.paymentsTable}) as total_payments,
          (SELECT SUM(${DatabaseConstants.productsFinalPrice}) FROM ${DatabaseConstants.productsTable}) as total_sales,
          (SELECT SUM(${DatabaseConstants.productsTotalPaid}) FROM ${DatabaseConstants.productsTable}) as total_collected,
          (SELECT SUM(${DatabaseConstants.productsFinalPrice} - ${DatabaseConstants.productsTotalPaid}) FROM ${DatabaseConstants.productsTable} WHERE ${DatabaseConstants.productsIsCompleted} = 0) as total_remaining,
          (SELECT SUM(${DatabaseConstants.productsFinalPrice} - ${DatabaseConstants.productsOriginalPrice}) FROM ${DatabaseConstants.productsTable}) as total_profit
      ''';

      final result = await _databaseHelper.rawQuery(sql);
      
      if (result.isNotEmpty) {
        final data = result.first;
        return {
          'total_customers': data['total_customers'] ?? 0,
          'total_products': data['total_products'] ?? 0,
          'completed_products': data['completed_products'] ?? 0,
          'active_products': data['active_products'] ?? 0,
          'total_payments': data['total_payments'] ?? 0,
          'total_sales': (data['total_sales'] as num?)?.toDouble() ?? 0.0,
          'total_collected': (data['total_collected'] as num?)?.toDouble() ?? 0.0,
          'total_remaining': (data['total_remaining'] as num?)?.toDouble() ?? 0.0,
          'total_profit': (data['total_profit'] as num?)?.toDouble() ?? 0.0,
        };
      }

      return _getEmptyStatistics();
    } catch (e) {
      throw Exception('فشل في تحميل الإحصائيات العامة: $e');
    }
  }

  // Get monthly statistics
  Future<List<Map<String, dynamic>>> getMonthlyStatistics({
    int? year,
    int monthsCount = 12,
  }) async {
    try {
      final currentYear = year ?? DateTime.now().year;
      final monthlyStats = <Map<String, dynamic>>[];

      for (int month = 1; month <= 12; month++) {
        final startDate = DateTime(currentYear, month, 1);
        final endDate = DateTime(currentYear, month + 1, 0);

        final sql = '''
          SELECT 
            COUNT(DISTINCT p.${DatabaseConstants.paymentsCustomerId}) as customers_count,
            COUNT(p.${DatabaseConstants.paymentsId}) as payments_count,
            SUM(p.${DatabaseConstants.paymentsAmount}) as total_amount,
            COUNT(DISTINCT pr.${DatabaseConstants.productsId}) as products_sold,
            SUM(pr.${DatabaseConstants.productsFinalPrice} - pr.${DatabaseConstants.productsOriginalPrice}) as profit
          FROM ${DatabaseConstants.paymentsTable} p
          LEFT JOIN ${DatabaseConstants.productsTable} pr ON p.${DatabaseConstants.paymentsProductId} = pr.${DatabaseConstants.productsId}
          WHERE date(p.${DatabaseConstants.paymentsDate}) BETWEEN date(?) AND date(?)
        ''';

        final result = await _databaseHelper.rawQuery(sql, [
          AppDateUtils.formatForDatabase(startDate),
          AppDateUtils.formatForDatabase(endDate),
        ]);

        final data = result.isNotEmpty ? result.first : {};
        
        monthlyStats.add({
          'month': month,
          'month_name': AppDateUtils.getMonthName(month),
          'year': currentYear,
          'customers_count': data['customers_count'] ?? 0,
          'payments_count': data['payments_count'] ?? 0,
          'total_amount': (data['total_amount'] as num?)?.toDouble() ?? 0.0,
          'products_sold': data['products_sold'] ?? 0,
          'profit': (data['profit'] as num?)?.toDouble() ?? 0.0,
        });
      }

      return monthlyStats;
    } catch (e) {
      throw Exception('فشل في تحميل الإحصائيات الشهرية: $e');
    }
  }

  // Get daily statistics for current month
  Future<List<Map<String, dynamic>>> getDailyStatistics({
    DateTime? targetMonth,
  }) async {
    try {
      final month = targetMonth ?? DateTime.now();
      final startDate = AppDateUtils.startOfMonth(month);
      final endDate = AppDateUtils.endOfMonth(month);

      final sql = '''
        SELECT 
          date(p.${DatabaseConstants.paymentsDate}) as payment_date,
          COUNT(p.${DatabaseConstants.paymentsId}) as payments_count,
          SUM(p.${DatabaseConstants.paymentsAmount}) as total_amount
        FROM ${DatabaseConstants.paymentsTable} p
        WHERE date(p.${DatabaseConstants.paymentsDate}) BETWEEN date(?) AND date(?)
        GROUP BY date(p.${DatabaseConstants.paymentsDate})
        ORDER BY payment_date ASC
      ''';

      final result = await _databaseHelper.rawQuery(sql, [
        AppDateUtils.formatForDatabase(startDate),
        AppDateUtils.formatForDatabase(endDate),
      ]);

      return result.map((data) => {
        'date': data['payment_date'],
        'payments_count': data['payments_count'] ?? 0,
        'total_amount': (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      }).toList();
    } catch (e) {
      throw Exception('فشل في تحميل الإحصائيات اليومية: $e');
    }
  }

  // Get top customers by revenue
  Future<List<Map<String, dynamic>>> getTopCustomers({int limit = 10}) async {
    try {
      final sql = '''
        SELECT 
          c.${DatabaseConstants.customersId},
          c.${DatabaseConstants.customersName},
          c.${DatabaseConstants.customersPhone},
          COUNT(pr.${DatabaseConstants.productsId}) as products_count,
          SUM(pr.${DatabaseConstants.productsFinalPrice}) as total_sales,
          SUM(pr.${DatabaseConstants.productsTotalPaid}) as total_paid,
          SUM(pr.${DatabaseConstants.productsFinalPrice} - pr.${DatabaseConstants.productsTotalPaid}) as remaining_amount,
          SUM(pr.${DatabaseConstants.productsFinalPrice} - pr.${DatabaseConstants.productsOriginalPrice}) as total_profit
        FROM ${DatabaseConstants.customersTable} c
        INNER JOIN ${DatabaseConstants.productsTable} pr ON c.${DatabaseConstants.customersId} = pr.${DatabaseConstants.productsCustomerId}
        GROUP BY c.${DatabaseConstants.customersId}
        ORDER BY total_sales DESC
        LIMIT ?
      ''';

      final result = await _databaseHelper.rawQuery(sql, [limit]);

      return result.map((data) => {
        'customer_id': data[DatabaseConstants.customersId],
        'customer_name': data[DatabaseConstants.customersName],
        'customer_phone': data[DatabaseConstants.customersPhone],
        'products_count': data['products_count'] ?? 0,
        'total_sales': (data['total_sales'] as num?)?.toDouble() ?? 0.0,
        'total_paid': (data['total_paid'] as num?)?.toDouble() ?? 0.0,
        'remaining_amount': (data['remaining_amount'] as num?)?.toDouble() ?? 0.0,
        'total_profit': (data['total_profit'] as num?)?.toDouble() ?? 0.0,
      }).toList();
    } catch (e) {
      throw Exception('فشل في تحميل أفضل العملاء: $e');
    }
  }

  // Get payment trends
  Future<Map<String, dynamic>> getPaymentTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? AppDateUtils.startOfMonth(DateTime.now());
      final end = endDate ?? AppDateUtils.endOfMonth(DateTime.now());

      // Current period statistics
      final currentSql = '''
        SELECT 
          COUNT(*) as payments_count,
          SUM(${DatabaseConstants.paymentsAmount}) as total_amount,
          AVG(${DatabaseConstants.paymentsAmount}) as average_amount
        FROM ${DatabaseConstants.paymentsTable}
        WHERE date(${DatabaseConstants.paymentsDate}) BETWEEN date(?) AND date(?)
      ''';

      final currentResult = await _databaseHelper.rawQuery(currentSql, [
        AppDateUtils.formatForDatabase(start),
        AppDateUtils.formatForDatabase(end),
      ]);

      // Previous period statistics (same duration)
      final duration = end.difference(start);
      final prevStart = start.subtract(duration);
      final prevEnd = start.subtract(const Duration(days: 1));

      final previousResult = await _databaseHelper.rawQuery(currentSql, [
        AppDateUtils.formatForDatabase(prevStart),
        AppDateUtils.formatForDatabase(prevEnd),
      ]);

      final current = currentResult.isNotEmpty ? currentResult.first : {};
      final previous = previousResult.isNotEmpty ? previousResult.first : {};

      final currentAmount = (current['total_amount'] as num?)?.toDouble() ?? 0.0;
      final previousAmount = (previous['total_amount'] as num?)?.toDouble() ?? 0.0;

      double percentageChange = 0.0;
      if (previousAmount > 0) {
        percentageChange = ((currentAmount - previousAmount) / previousAmount) * 100;
      }

      return {
        'current_period': {
          'payments_count': current['payments_count'] ?? 0,
          'total_amount': currentAmount,
          'average_amount': (current['average_amount'] as num?)?.toDouble() ?? 0.0,
        },
        'previous_period': {
          'payments_count': previous['payments_count'] ?? 0,
          'total_amount': previousAmount,
          'average_amount': (previous['average_amount'] as num?)?.toDouble() ?? 0.0,
        },
        'percentage_change': percentageChange,
        'trend': percentageChange > 0 ? 'increasing' : percentageChange < 0 ? 'decreasing' : 'stable',
      };
    } catch (e) {
      throw Exception('فشل في تحميل اتجاهات المدفوعات: $e');
    }
  }

  // Get overdue statistics
  Future<Map<String, dynamic>> getOverdueStatistics() async {
    try {
      final sql = '''
        SELECT 
          COUNT(DISTINCT p.${DatabaseConstants.productsId}) as overdue_products,
          COUNT(DISTINCT c.${DatabaseConstants.customersId}) as overdue_customers,
          SUM(p.${DatabaseConstants.productsFinalPrice} - p.${DatabaseConstants.productsTotalPaid}) as overdue_amount
        FROM ${DatabaseConstants.productsTable} p
        INNER JOIN ${DatabaseConstants.customersTable} c ON p.${DatabaseConstants.productsCustomerId} = c.${DatabaseConstants.customersId}
        LEFT JOIN (
          SELECT 
            ${DatabaseConstants.paymentsProductId},
            MAX(${DatabaseConstants.paymentsNextDueDate}) as next_due_date
          FROM ${DatabaseConstants.paymentsTable}
          WHERE ${DatabaseConstants.paymentsNextDueDate} IS NOT NULL
          GROUP BY ${DatabaseConstants.paymentsProductId}
        ) pay ON p.${DatabaseConstants.productsId} = pay.${DatabaseConstants.paymentsProductId}
        WHERE p.${DatabaseConstants.productsIsCompleted} = 0
          AND (pay.next_due_date < date('now') OR pay.next_due_date IS NULL)
      ''';

      final result = await _databaseHelper.rawQuery(sql);
      
      if (result.isNotEmpty) {
        final data = result.first;
        return {
          'overdue_products': data['overdue_products'] ?? 0,
          'overdue_customers': data['overdue_customers'] ?? 0,
          'overdue_amount': (data['overdue_amount'] as num?)?.toDouble() ?? 0.0,
        };
      }

      return {
        'overdue_products': 0,
        'overdue_customers': 0,
        'overdue_amount': 0.0,
      };
    } catch (e) {
      throw Exception('فشل في تحميل إحصائيات المتأخرات: $e');
    }
  }

  // Get product categories statistics
  Future<List<Map<String, dynamic>>> getProductCategoriesStatistics() async {
    try {
      // Since we don't have categories in the current schema, we'll analyze by price ranges
      final sql = '''
        SELECT 
          CASE 
            WHEN ${DatabaseConstants.productsFinalPrice} < 1000 THEN 'أقل من 1000'
            WHEN ${DatabaseConstants.productsFinalPrice} < 5000 THEN '1000 - 5000'
            WHEN ${DatabaseConstants.productsFinalPrice} < 10000 THEN '5000 - 10000'
            ELSE 'أكثر من 10000'
          END as price_range,
          COUNT(*) as products_count,
          SUM(${DatabaseConstants.productsFinalPrice}) as total_sales,
          SUM(${DatabaseConstants.productsTotalPaid}) as total_paid,
          SUM(${DatabaseConstants.productsFinalPrice} - ${DatabaseConstants.productsOriginalPrice}) as total_profit
        FROM ${DatabaseConstants.productsTable}
        GROUP BY price_range
        ORDER BY total_sales DESC
      ''';

      final result = await _databaseHelper.rawQuery(sql);

      return result.map((data) => {
        'category': data['price_range'],
        'products_count': data['products_count'] ?? 0,
        'total_sales': (data['total_sales'] as num?)?.toDouble() ?? 0.0,
        'total_paid': (data['total_paid'] as num?)?.toDouble() ?? 0.0,
        'total_profit': (data['total_profit'] as num?)?.toDouble() ?? 0.0,
      }).toList();
    } catch (e) {
      throw Exception('فشل في تحميل إحصائيات فئات المنتجات: $e');
    }
  }

  // Get recent activity
  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 20}) async {
    try {
      final sql = '''
        SELECT 
          'payment' as activity_type,
          p.${DatabaseConstants.paymentsDate} as activity_date,
          p.${DatabaseConstants.paymentsAmount} as amount,
          c.${DatabaseConstants.customersName} as customer_name,
          pr.${DatabaseConstants.productsName} as product_name,
          p.${DatabaseConstants.paymentsReceiptNumber} as receipt_number
        FROM ${DatabaseConstants.paymentsTable} p
        INNER JOIN ${DatabaseConstants.customersTable} c ON p.${DatabaseConstants.paymentsCustomerId} = c.${DatabaseConstants.customersId}
        INNER JOIN ${DatabaseConstants.productsTable} pr ON p.${DatabaseConstants.paymentsProductId} = pr.${DatabaseConstants.productsId}
        
        UNION ALL
        
        SELECT 
          'product' as activity_type,
          pr.${DatabaseConstants.productsSaleDate} as activity_date,
          pr.${DatabaseConstants.productsFinalPrice} as amount,
          c.${DatabaseConstants.customersName} as customer_name,
          pr.${DatabaseConstants.productsName} as product_name,
          NULL as receipt_number
        FROM ${DatabaseConstants.productsTable} pr
        INNER JOIN ${DatabaseConstants.customersTable} c ON pr.${DatabaseConstants.productsCustomerId} = c.${DatabaseConstants.customersId}
        
        ORDER BY activity_date DESC
        LIMIT ?
      ''';

      final result = await _databaseHelper.rawQuery(sql, [limit]);

      return result.map((data) => {
        'activity_type': data['activity_type'],
        'activity_date': data['activity_date'],
        'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
        'customer_name': data['customer_name'],
        'product_name': data['product_name'],
        'receipt_number': data['receipt_number'],
      }).toList();
    } catch (e) {
      throw Exception('فشل في تحميل النشاط الحديث: $e');
    }
  }

  // Get collection efficiency
  Future<Map<String, dynamic>> getCollectionEfficiency() async {
    try {
      final sql = '''
        SELECT 
          COUNT(*) as total_products,
          COUNT(CASE WHEN ${DatabaseConstants.productsIsCompleted} = 1 THEN 1 END) as completed_products,
          AVG(${DatabaseConstants.productsTotalPaid} * 100.0 / ${DatabaseConstants.productsFinalPrice}) as average_collection_rate,
          SUM(${DatabaseConstants.productsFinalPrice}) as total_sales,
          SUM(${DatabaseConstants.productsTotalPaid}) as total_collected
        FROM ${DatabaseConstants.productsTable}
        WHERE ${DatabaseConstants.productsFinalPrice} > 0
      ''';

      final result = await _databaseHelper.rawQuery(sql);
      
      if (result.isNotEmpty) {
        final data = result.first;
        final totalProducts = data['total_products'] ?? 0;
        final completedProducts = data['completed_products'] ?? 0;
        final totalSales = (data['total_sales'] as num?)?.toDouble() ?? 0.0;
        final totalCollected = (data['total_collected'] as num?)?.toDouble() ?? 0.0;
        
        return {
          'total_products': totalProducts,
          'completed_products': completedProducts,
          'completion_rate': totalProducts > 0 ? (completedProducts / totalProducts) * 100 : 0.0,
          'average_collection_rate': (data['average_collection_rate'] as num?)?.toDouble() ?? 0.0,
          'overall_collection_rate': totalSales > 0 ? (totalCollected / totalSales) * 100 : 0.0,
          'total_sales': totalSales,
          'total_collected': totalCollected,
        };
      }

      return {
        'total_products': 0,
        'completed_products': 0,
        'completion_rate': 0.0,
        'average_collection_rate': 0.0,
        'overall_collection_rate': 0.0,
        'total_sales': 0.0,
        'total_collected': 0.0,
      };
    } catch (e) {
      throw Exception('فشل في تحميل كفاءة التحصيل: $e');
    }
  }

  // Private helper method
  Map<String, dynamic> _getEmptyStatistics() {
    return {
      'total_customers': 0,
      'total_products': 0,
      'completed_products': 0,
      'active_products': 0,
      'total_payments': 0,
      'total_sales': 0.0,
      'total_collected': 0.0,
      'total_remaining': 0.0,
      'total_profit': 0.0,
    };
  }
}

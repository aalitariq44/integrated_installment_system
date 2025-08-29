import '../../../core/database/database_helper.dart';
import '../../../core/database/models/payment_model.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';

class PaymentsRepository {
  final DatabaseHelper _databaseHelper;

  PaymentsRepository({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  // Get all payments
  Future<List<PaymentModel>> getAllPayments({
    int? limit,
    int? offset,
  }) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.paymentsTable,
        orderBy: '${DatabaseConstants.paymentsDate} DESC',
        limit: limit,
        offset: offset,
      );

      return results.map((json) => PaymentModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل المدفوعات: $e');
    }
  }

  // Get payments by product ID
  Future<List<PaymentModel>> getPaymentsByProductId(int productId) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.paymentsTable,
        where: '${DatabaseConstants.paymentsProductId} = ?',
        whereArgs: [productId],
        orderBy: '${DatabaseConstants.paymentsDate} DESC',
      );

      return results.map((json) => PaymentModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل مدفوعات المنتج: $e');
    }
  }

  // Get payments by customer ID
  Future<List<PaymentModel>> getPaymentsByCustomerId(int customerId) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.paymentsTable,
        where: '${DatabaseConstants.paymentsCustomerId} = ?',
        whereArgs: [customerId],
        orderBy: '${DatabaseConstants.paymentsDate} DESC',
      );

      return results.map((json) => PaymentModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل مدفوعات العميل: $e');
    }
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(int paymentId) async {
    try {
      final result = await _databaseHelper.queryFirst(
        DatabaseConstants.paymentsTable,
        where: '${DatabaseConstants.paymentsId} = ?',
        whereArgs: [paymentId],
      );

      if (result != null) {
        return PaymentModel.fromMap(result);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في تحميل بيانات الدفعة: $e');
    }
  }

  // Add new payment
  Future<int> addPayment(PaymentModel payment) async {
    try {
      return await _databaseHelper.transaction((txn) async {
        final now = DateTime.now();
        
        // Generate receipt number if not provided
        String receiptNumber = payment.receiptNumber ?? await _generateReceiptNumber();
        
        // Calculate next due date based on product interval
        DateTime? nextDueDate;
        if (payment.paymentDate != null) {
          final productResult = await txn.query(
            DatabaseConstants.productsTable,
            columns: [DatabaseConstants.productsPaymentInterval],
            where: '${DatabaseConstants.productsId} = ?',
            whereArgs: [payment.productId],
          );
          
          if (productResult.isNotEmpty) {
            final intervalDays = productResult.first[DatabaseConstants.productsPaymentInterval] as int;
            nextDueDate = AppDateUtils.calculateNextDueDate(
              payment.paymentDate!,
              intervalDays,
            );
          }
        }

        final paymentData = payment.copyWith(
          paymentDate: payment.paymentDate ?? now,
          nextDueDate: nextDueDate,
          receiptNumber: receiptNumber,
          createdDate: now,
        ).toMap();

        // Insert payment
        final paymentId = await txn.insert(
          DatabaseConstants.paymentsTable,
          paymentData,
        );

        // Update product total paid amount
        await _updateProductTotalPaid(txn, payment.productId);

        return paymentId;
      });
    } catch (e) {
      throw Exception('فشل في إضافة الدفعة: $e');
    }
  }

  // Update payment
  Future<bool> updatePayment(PaymentModel payment) async {
    try {
      if (payment.paymentId == null) {
        throw Exception('معرف الدفعة مطلوب للتحديث');
      }

      return await _databaseHelper.transaction((txn) async {
        final paymentData = payment.toMap();

        final updateCount = await txn.update(
          DatabaseConstants.paymentsTable,
          paymentData,
          where: '${DatabaseConstants.paymentsId} = ?',
          whereArgs: [payment.paymentId],
        );

        if (updateCount > 0) {
          // Update product total paid amount
          await _updateProductTotalPaid(txn, payment.productId);
          return true;
        }

        return false;
      });
    } catch (e) {
      throw Exception('فشل في تحديث بيانات الدفعة: $e');
    }
  }

  // Delete payment
  Future<bool> deletePayment(int paymentId) async {
    try {
      return await _databaseHelper.transaction((txn) async {
        // Get payment details before deletion
        final paymentResult = await txn.query(
          DatabaseConstants.paymentsTable,
          where: '${DatabaseConstants.paymentsId} = ?',
          whereArgs: [paymentId],
        );

        if (paymentResult.isEmpty) {
          throw Exception('الدفعة غير موجودة');
        }

        final payment = PaymentModel.fromMap(paymentResult.first);

        // Delete payment
        final deleteCount = await txn.delete(
          DatabaseConstants.paymentsTable,
          where: '${DatabaseConstants.paymentsId} = ?',
          whereArgs: [paymentId],
        );

        if (deleteCount > 0) {
          // Update product total paid amount
          await _updateProductTotalPaid(txn, payment.productId);
          return true;
        }

        return false;
      });
    } catch (e) {
      throw Exception('فشل في حذف الدفعة: $e');
    }
  }

  // Get payment history with details
  Future<List<Map<String, dynamic>>> getPaymentHistoryWithDetails({
    int? customerId,
    int? productId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause += ' AND p.${DatabaseConstants.paymentsCustomerId} = ?';
        whereArgs.add(customerId);
      }

      if (productId != null) {
        whereClause += ' AND p.${DatabaseConstants.paymentsProductId} = ?';
        whereArgs.add(productId);
      }

      if (startDate != null) {
        whereClause += ' AND date(p.${DatabaseConstants.paymentsDate}) >= date(?)';
        whereArgs.add(AppDateUtils.formatForDatabase(startDate));
      }

      if (endDate != null) {
        whereClause += ' AND date(p.${DatabaseConstants.paymentsDate}) <= date(?)';
        whereArgs.add(AppDateUtils.formatForDatabase(endDate));
      }

      final sql = '''
        SELECT 
          p.*,
          c.${DatabaseConstants.customersName} as customer_name,
          c.${DatabaseConstants.customersPhone} as customer_phone,
          pr.${DatabaseConstants.productsName} as product_name,
          pr.${DatabaseConstants.productsFinalPrice} as product_price
        FROM ${DatabaseConstants.paymentsTable} p
        INNER JOIN ${DatabaseConstants.customersTable} c ON p.${DatabaseConstants.paymentsCustomerId} = c.${DatabaseConstants.customersId}
        INNER JOIN ${DatabaseConstants.productsTable} pr ON p.${DatabaseConstants.paymentsProductId} = pr.${DatabaseConstants.productsId}
        WHERE $whereClause
        ORDER BY p.${DatabaseConstants.paymentsDate} DESC
      ''';

      return await _databaseHelper.rawQuery(sql, whereArgs);
    } catch (e) {
      throw Exception('فشل في تحميل تاريخ المدفوعات: $e');
    }
  }

  // Get total payments amount
  Future<double> getTotalPaymentsAmount({
    int? customerId,
    int? productId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause += ' AND ${DatabaseConstants.paymentsCustomerId} = ?';
        whereArgs.add(customerId);
      }

      if (productId != null) {
        whereClause += ' AND ${DatabaseConstants.paymentsProductId} = ?';
        whereArgs.add(productId);
      }

      if (startDate != null) {
        whereClause += ' AND date(${DatabaseConstants.paymentsDate}) >= date(?)';
        whereArgs.add(AppDateUtils.formatForDatabase(startDate));
      }

      if (endDate != null) {
        whereClause += ' AND date(${DatabaseConstants.paymentsDate}) <= date(?)';
        whereArgs.add(AppDateUtils.formatForDatabase(endDate));
      }

      final sql = '''
        SELECT SUM(${DatabaseConstants.paymentsAmount}) as total_amount
        FROM ${DatabaseConstants.paymentsTable}
        WHERE $whereClause
      ''';

      final result = await _databaseHelper.rawQuery(sql, whereArgs);
      
      if (result.isNotEmpty && result.first['total_amount'] != null) {
        return (result.first['total_amount'] as num).toDouble();
      }

      return 0.0;
    } catch (e) {
      throw Exception('فشل في حساب إجمالي المدفوعات: $e');
    }
  }

  // Get recent payments
  Future<List<PaymentModel>> getRecentPayments({int limit = 10}) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.paymentsTable,
        orderBy: '${DatabaseConstants.paymentsDate} DESC',
        limit: limit,
      );

      return results.map((json) => PaymentModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل المدفوعات الحديثة: $e');
    }
  }

  // Get payments statistics
  Future<Map<String, dynamic>> getPaymentsStatistics({
    int? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause += ' AND ${DatabaseConstants.paymentsCustomerId} = ?';
        whereArgs.add(customerId);
      }

      if (startDate != null) {
        whereClause += ' AND date(${DatabaseConstants.paymentsDate}) >= date(?)';
        whereArgs.add(AppDateUtils.formatForDatabase(startDate));
      }

      if (endDate != null) {
        whereClause += ' AND date(${DatabaseConstants.paymentsDate}) <= date(?)';
        whereArgs.add(AppDateUtils.formatForDatabase(endDate));
      }

      final sql = '''
        SELECT 
          COUNT(*) as total_payments,
          SUM(${DatabaseConstants.paymentsAmount}) as total_amount,
          AVG(${DatabaseConstants.paymentsAmount}) as average_amount,
          MIN(${DatabaseConstants.paymentsAmount}) as min_amount,
          MAX(${DatabaseConstants.paymentsAmount}) as max_amount
        FROM ${DatabaseConstants.paymentsTable}
        WHERE $whereClause
      ''';

      final result = await _databaseHelper.rawQuery(sql, whereArgs);
      
      if (result.isNotEmpty) {
        return result.first;
      }

      return {
        'total_payments': 0,
        'total_amount': 0.0,
        'average_amount': 0.0,
        'min_amount': 0.0,
        'max_amount': 0.0,
      };
    } catch (e) {
      throw Exception('فشل في تحميل إحصائيات المدفوعات: $e');
    }
  }

  // Check if receipt number is unique
  Future<bool> isReceiptNumberUnique(String receiptNumber, {int? excludePaymentId}) async {
    try {
      String whereClause = '${DatabaseConstants.paymentsReceiptNumber} = ?';
      List<dynamic> whereArgs = [receiptNumber];

      if (excludePaymentId != null) {
        whereClause += ' AND ${DatabaseConstants.paymentsId} != ?';
        whereArgs.add(excludePaymentId);
      }

      final result = await _databaseHelper.queryFirst(
        DatabaseConstants.paymentsTable,
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result == null;
    } catch (e) {
      return true; // Assume unique if error occurs
    }
  }

  // Get payments count
  Future<int> getPaymentsCount({int? customerId, int? productId}) async {
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause = '${DatabaseConstants.paymentsCustomerId} = ?';
        whereArgs.add(customerId);
      } else if (productId != null) {
        whereClause = '${DatabaseConstants.paymentsProductId} = ?';
        whereArgs.add(productId);
      }

      return await _databaseHelper.count(
        DatabaseConstants.paymentsTable,
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );
    } catch (e) {
      throw Exception('فشل في عد المدفوعات: $e');
    }
  }

  // Export payments data
  Future<List<Map<String, dynamic>>> exportPaymentsData({
    int? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause += ' AND ${DatabaseConstants.paymentsCustomerId} = ?';
        whereArgs.add(customerId);
      }

      if (startDate != null) {
        whereClause += ' AND date(${DatabaseConstants.paymentsDate}) >= date(?)';
        whereArgs.add(AppDateUtils.formatForDatabase(startDate));
      }

      if (endDate != null) {
        whereClause += ' AND date(${DatabaseConstants.paymentsDate}) <= date(?)';
        whereArgs.add(AppDateUtils.formatForDatabase(endDate));
      }

      return await _databaseHelper.query(
        DatabaseConstants.paymentsTable,
        where: whereClause != '1=1' ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: '${DatabaseConstants.paymentsDate} DESC',
      );
    } catch (e) {
      throw Exception('فشل في تصدير بيانات المدفوعات: $e');
    }
  }

  // Private helper methods
  Future<String> _generateReceiptNumber() async {
    try {
      final count = await getPaymentsCount();
      final receiptNumber = '${AppConstants.receiptPrefix}${(count + 1).toString().padLeft(AppConstants.receiptNumberLength, '0')}';
      
      // Ensure uniqueness
      final isUnique = await isReceiptNumberUnique(receiptNumber);
      if (!isUnique) {
        // If not unique, use timestamp
        return '${AppConstants.receiptPrefix}${DateTime.now().millisecondsSinceEpoch}';
      }
      
      return receiptNumber;
    } catch (e) {
      // Fallback to timestamp
      return '${AppConstants.receiptPrefix}${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _updateProductTotalPaid(dynamic txn, int productId) async {
    // Calculate total paid for the product
    final totalPaidResult = await txn.rawQuery('''
      SELECT SUM(${DatabaseConstants.paymentsAmount}) as total_paid
      FROM ${DatabaseConstants.paymentsTable}
      WHERE ${DatabaseConstants.paymentsProductId} = ?
    ''', [productId]);

    double totalPaid = 0.0;
    if (totalPaidResult.isNotEmpty && totalPaidResult.first['total_paid'] != null) {
      totalPaid = (totalPaidResult.first['total_paid'] as num).toDouble();
    }

    // Get product final price
    final productResult = await txn.query(
      DatabaseConstants.productsTable,
      columns: [DatabaseConstants.productsFinalPrice],
      where: '${DatabaseConstants.productsId} = ?',
      whereArgs: [productId],
    );

    if (productResult.isNotEmpty) {
      final finalPrice = (productResult.first[DatabaseConstants.productsFinalPrice] as num).toDouble();
      final remainingAmount = finalPrice - totalPaid;
      final isCompleted = totalPaid >= finalPrice;

      // Update product
      await txn.update(
        DatabaseConstants.productsTable,
        {
          DatabaseConstants.productsTotalPaid: totalPaid,
          DatabaseConstants.productsRemainingAmount: remainingAmount,
          DatabaseConstants.productsIsCompleted: isCompleted ? 1 : 0,
          DatabaseConstants.productsUpdatedDate: DateTime.now().toIso8601String(),
        },
        where: '${DatabaseConstants.productsId} = ?',
        whereArgs: [productId],
      );
    }
  }
}

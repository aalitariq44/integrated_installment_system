import '../../../core/database/database_helper.dart';
import '../../../core/database/models/customer_model.dart';
import '../../../core/constants/database_constants.dart';

class CustomersRepository {
  final DatabaseHelper _databaseHelper;

  CustomersRepository({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  // Get all customers
  Future<List<CustomerModel>> getAllCustomers({
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      List<Map<String, dynamic>> results;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        results = await _databaseHelper.search(
          DatabaseConstants.customersTable,
          [
            DatabaseConstants.customersName,
            DatabaseConstants.customersPhone,
          ],
          searchQuery,
          orderBy: '${DatabaseConstants.customersName} ASC',
          limit: limit,
        );
      } else {
        results = await _databaseHelper.query(
          DatabaseConstants.customersTable,
          orderBy: '${DatabaseConstants.customersName} ASC',
          limit: limit,
          offset: offset,
        );
      }

      return results.map((json) => CustomerModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل العملاء: $e');
    }
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(int customerId) async {
    try {
      final result = await _databaseHelper.queryFirst(
        DatabaseConstants.customersTable,
        where: '${DatabaseConstants.customersId} = ?',
        whereArgs: [customerId],
      );

      if (result != null) {
        return CustomerModel.fromMap(result);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في تحميل بيانات العميل: $e');
    }
  }

  // Add new customer
  Future<int> addCustomer(CustomerModel customer) async {
    try {
      final now = DateTime.now();
      final customerData = customer.copyWith(
        createdDate: now,
        updatedDate: now,
      ).toMap();

      return await _databaseHelper.insert(
        DatabaseConstants.customersTable,
        customerData,
      );
    } catch (e) {
      throw Exception('فشل في إضافة العميل: $e');
    }
  }

  // Update customer
  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      if (customer.customerId == null) {
        throw Exception('معرف العميل مطلوب للتحديث');
      }

      final now = DateTime.now();
      final customerData = customer.copyWith(
        updatedDate: now,
      ).toMap();

      final updateCount = await _databaseHelper.update(
        DatabaseConstants.customersTable,
        customerData,
        where: '${DatabaseConstants.customersId} = ?',
        whereArgs: [customer.customerId],
      );

      return updateCount > 0;
    } catch (e) {
      throw Exception('فشل في تحديث بيانات العميل: $e');
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(int customerId) async {
    try {
      final deleteCount = await _databaseHelper.delete(
        DatabaseConstants.customersTable,
        where: '${DatabaseConstants.customersId} = ?',
        whereArgs: [customerId],
      );

      return deleteCount > 0;
    } catch (e) {
      throw Exception('فشل في حذف العميل: $e');
    }
  }

  // Search customers
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllCustomers();
      }

      final results = await _databaseHelper.search(
        DatabaseConstants.customersTable,
        [
          DatabaseConstants.customersName,
          DatabaseConstants.customersPhone,
          DatabaseConstants.customersAddress,
        ],
        query,
        orderBy: '${DatabaseConstants.customersName} ASC',
      );

      return results.map((json) => CustomerModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في البحث عن العملاء: $e');
    }
  }

  // Get customers count
  Future<int> getCustomersCount() async {
    try {
      return await _databaseHelper.count(DatabaseConstants.customersTable);
    } catch (e) {
      throw Exception('فشل في عد العملاء: $e');
    }
  }

  // Check if customer exists
  Future<bool> customerExists(int customerId) async {
    try {
      final customer = await getCustomerById(customerId);
      return customer != null;
    } catch (e) {
      return false;
    }
  }

  // Check if phone number is unique
  Future<bool> isPhoneUnique(String phoneNumber, {int? excludeCustomerId}) async {
    try {
      String whereClause = '${DatabaseConstants.customersPhone} = ?';
      List<dynamic> whereArgs = [phoneNumber];

      if (excludeCustomerId != null) {
        whereClause += ' AND ${DatabaseConstants.customersId} != ?';
        whereArgs.add(excludeCustomerId);
      }

      final result = await _databaseHelper.queryFirst(
        DatabaseConstants.customersTable,
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result == null;
    } catch (e) {
      return true; // Assume unique if error occurs
    }
  }

  // Get customers with overdue payments
  Future<List<Map<String, dynamic>>> getCustomersWithOverduePayments() async {
    try {
      final sql = '''
        SELECT DISTINCT 
          c.${DatabaseConstants.customersId},
          c.${DatabaseConstants.customersName},
          c.${DatabaseConstants.customersPhone},
          COUNT(p.${DatabaseConstants.productsId}) as product_count,
          SUM(p.${DatabaseConstants.productsFinalPrice} - p.${DatabaseConstants.productsTotalPaid}) as total_remaining
        FROM ${DatabaseConstants.customersTable} c
        INNER JOIN ${DatabaseConstants.productsTable} p ON c.${DatabaseConstants.customersId} = p.${DatabaseConstants.productsCustomerId}
        LEFT JOIN ${DatabaseConstants.paymentsTable} pay ON p.${DatabaseConstants.productsId} = pay.${DatabaseConstants.paymentsProductId}
        WHERE p.${DatabaseConstants.productsIsCompleted} = 0
          AND pay.${DatabaseConstants.paymentsNextDueDate} < date('now')
        GROUP BY c.${DatabaseConstants.customersId}
        ORDER BY c.${DatabaseConstants.customersName}
      ''';

      return await _databaseHelper.rawQuery(sql);
    } catch (e) {
      throw Exception('فشل في تحميل العملاء المتأخرين: $e');
    }
  }

  // Get customer statistics
  Future<Map<String, dynamic>> getCustomerStatistics(int customerId) async {
    try {
      final sql = '''
        SELECT 
          COUNT(p.${DatabaseConstants.productsId}) as total_products,
          COUNT(CASE WHEN p.${DatabaseConstants.productsIsCompleted} = 1 THEN 1 END) as completed_products,
          SUM(p.${DatabaseConstants.productsFinalPrice}) as total_amount,
          SUM(p.${DatabaseConstants.productsTotalPaid}) as total_paid,
          SUM(p.${DatabaseConstants.productsFinalPrice} - p.${DatabaseConstants.productsTotalPaid}) as remaining_amount
        FROM ${DatabaseConstants.productsTable} p
        WHERE p.${DatabaseConstants.productsCustomerId} = ?
      ''';

      final result = await _databaseHelper.rawQuery(sql, [customerId]);
      
      if (result.isNotEmpty) {
        return result.first;
      }

      return {
        'total_products': 0,
        'completed_products': 0,
        'total_amount': 0.0,
        'total_paid': 0.0,
        'remaining_amount': 0.0,
      };
    } catch (e) {
      throw Exception('فشل في تحميل إحصائيات العميل: $e');
    }
  }

  // Get recent customers
  Future<List<CustomerModel>> getRecentCustomers({int limit = 10}) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.customersTable,
        orderBy: '${DatabaseConstants.customersCreatedDate} DESC',
        limit: limit,
      );

      return results.map((json) => CustomerModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل العملاء الحديثين: $e');
    }
  }

  // Batch operations
  Future<List<int>> addMultipleCustomers(List<CustomerModel> customers) async {
    try {
      final ids = <int>[];
      
      await _databaseHelper.transaction((txn) async {
        for (final customer in customers) {
          final now = DateTime.now();
          final customerData = customer.copyWith(
            createdDate: now,
            updatedDate: now,
          ).toMap();

          final id = await txn.insert(
            DatabaseConstants.customersTable,
            customerData,
          );
          ids.add(id);
        }
      });

      return ids;
    } catch (e) {
      throw Exception('فشل في إضافة العملاء: $e');
    }
  }

  // Export customers data
  Future<List<Map<String, dynamic>>> exportCustomersData() async {
    try {
      return await _databaseHelper.query(
        DatabaseConstants.customersTable,
        orderBy: '${DatabaseConstants.customersName} ASC',
      );
    } catch (e) {
      throw Exception('فشل في تصدير بيانات العملاء: $e');
    }
  }
}

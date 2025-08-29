import '../../../core/database/database_helper.dart';
import '../../../core/database/models/product_model.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/utils/date_utils.dart';

class ProductsRepository {
  final DatabaseHelper _databaseHelper;

  ProductsRepository({required DatabaseHelper databaseHelper})
    : _databaseHelper = databaseHelper;

  // Get all products
  Future<List<ProductModel>> getAllProducts({
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      List<Map<String, dynamic>> results;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        results = await _databaseHelper.search(
          DatabaseConstants.productsTable,
          [DatabaseConstants.productsName, DatabaseConstants.productsDetails],
          searchQuery,
          orderBy: '${DatabaseConstants.productsSaleDate} DESC',
          limit: limit,
        );
      } else {
        results = await _databaseHelper.query(
          DatabaseConstants.productsTable,
          orderBy: '${DatabaseConstants.productsSaleDate} DESC',
          limit: limit,
          offset: offset,
        );
      }

      return results.map((json) => ProductModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل المنتجات: $e');
    }
  }

  // Get products by customer ID
  Future<List<ProductModel>> getProductsByCustomerId(int customerId) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.productsTable,
        where: '${DatabaseConstants.productsCustomerId} = ?',
        whereArgs: [customerId],
        orderBy: '${DatabaseConstants.productsSaleDate} DESC',
      );

      return results.map((json) => ProductModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل منتجات العميل: $e');
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(int productId) async {
    try {
      final result = await _databaseHelper.queryFirst(
        DatabaseConstants.productsTable,
        where: '${DatabaseConstants.productsId} = ?',
        whereArgs: [productId],
      );

      if (result != null) {
        return ProductModel.fromMap(result);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في تحميل بيانات المنتج: $e');
    }
  }

  // Add new product
  Future<int> addProduct(ProductModel product) async {
    try {
      final now = DateTime.now();
      final productData = product
          .copyWith(
            saleDate: product.saleDate ?? now,
            remainingAmount: product.finalPrice - product.totalPaid,
            createdDate: now,
            updatedDate: now,
          )
          .toMap();

      return await _databaseHelper.insert(
        DatabaseConstants.productsTable,
        productData,
      );
    } catch (e) {
      throw Exception('فشل في إضافة المنتج: $e');
    }
  }

  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      if (product.productId == null) {
        throw Exception('معرف المنتج مطلوب للتحديث');
      }

      final now = DateTime.now();
      final productData = product
          .copyWith(
            remainingAmount: product.finalPrice - product.totalPaid,
            updatedDate: now,
          )
          .toMap();

      final updateCount = await _databaseHelper.update(
        DatabaseConstants.productsTable,
        productData,
        where: '${DatabaseConstants.productsId} = ?',
        whereArgs: [product.productId],
      );

      return updateCount > 0;
    } catch (e) {
      throw Exception('فشل في تحديث بيانات المنتج: $e');
    }
  }

  // Delete product
  Future<bool> deleteProduct(int productId) async {
    try {
      final deleteCount = await _databaseHelper.delete(
        DatabaseConstants.productsTable,
        where: '${DatabaseConstants.productsId} = ?',
        whereArgs: [productId],
      );

      return deleteCount > 0;
    } catch (e) {
      throw Exception('فشل في حذف المنتج: $e');
    }
  }

  // Update product total paid amount
  Future<bool> updateProductTotalPaid(
    int productId,
    double newTotalPaid,
  ) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('المنتج غير موجود');
      }

      final updatedProduct = product.copyWith(
        totalPaid: newTotalPaid,
        remainingAmount: product.finalPrice - newTotalPaid,
        isCompleted: newTotalPaid >= product.finalPrice,
        updatedDate: DateTime.now(),
      );

      return await updateProduct(updatedProduct);
    } catch (e) {
      throw Exception('فشل في تحديث إجمالي المدفوع: $e');
    }
  }

  // Mark product as completed
  Future<bool> markProductAsCompleted(int productId) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('المنتج غير موجود');
      }

      final updatedProduct = product.copyWith(
        totalPaid: product.finalPrice,
        remainingAmount: 0,
        isCompleted: true,
        updatedDate: DateTime.now(),
      );

      return await updateProduct(updatedProduct);
    } catch (e) {
      throw Exception('فشل في تحديد المنتج كمكتمل: $e');
    }
  }

  // Get overdue products
  Future<List<Map<String, dynamic>>> getOverdueProducts() async {
    try {
      final sql =
          '''
        SELECT 
          p.*,
          c.${DatabaseConstants.customersName} as customer_name,
          c.${DatabaseConstants.customersPhone} as customer_phone,
          pay.${DatabaseConstants.paymentsNextDueDate} as next_due_date
        FROM ${DatabaseConstants.productsTable} p
        INNER JOIN ${DatabaseConstants.customersTable} c ON p.${DatabaseConstants.productsCustomerId} = c.${DatabaseConstants.customersId}
        LEFT JOIN (
          SELECT 
            ${DatabaseConstants.paymentsProductId},
            MAX(${DatabaseConstants.paymentsNextDueDate}) as ${DatabaseConstants.paymentsNextDueDate}
          FROM ${DatabaseConstants.paymentsTable}
          GROUP BY ${DatabaseConstants.paymentsProductId}
        ) pay ON p.${DatabaseConstants.productsId} = pay.${DatabaseConstants.paymentsProductId}
        WHERE p.${DatabaseConstants.productsIsCompleted} = 0
          AND (pay.${DatabaseConstants.paymentsNextDueDate} < date('now') OR pay.${DatabaseConstants.paymentsNextDueDate} IS NULL)
        ORDER BY pay.${DatabaseConstants.paymentsNextDueDate} ASC, p.${DatabaseConstants.productsSaleDate} ASC
      ''';

      return await _databaseHelper.rawQuery(sql);
    } catch (e) {
      throw Exception('فشل في تحميل المنتجات المتأخرة: $e');
    }
  }

  // Get products due soon
  Future<List<Map<String, dynamic>>> getProductsDueSoon({
    int daysThreshold = 3,
  }) async {
    try {
      final futureDate = AppDateUtils.addDays(DateTime.now(), daysThreshold);

      final sql =
          '''
        SELECT 
          p.*,
          c.${DatabaseConstants.customersName} as customer_name,
          c.${DatabaseConstants.customersPhone} as customer_phone,
          pay.${DatabaseConstants.paymentsNextDueDate} as next_due_date
        FROM ${DatabaseConstants.productsTable} p
        INNER JOIN ${DatabaseConstants.customersTable} c ON p.${DatabaseConstants.productsCustomerId} = c.${DatabaseConstants.customersId}
        LEFT JOIN (
          SELECT 
            ${DatabaseConstants.paymentsProductId},
            MAX(${DatabaseConstants.paymentsNextDueDate}) as ${DatabaseConstants.paymentsNextDueDate}
          FROM ${DatabaseConstants.paymentsTable}
          GROUP BY ${DatabaseConstants.paymentsProductId}
        ) pay ON p.${DatabaseConstants.productsId} = pay.${DatabaseConstants.paymentsProductId}
        WHERE p.${DatabaseConstants.productsIsCompleted} = 0
          AND pay.${DatabaseConstants.paymentsNextDueDate} BETWEEN date('now') AND date(?)
        ORDER BY pay.${DatabaseConstants.paymentsNextDueDate} ASC
      ''';

      return await _databaseHelper.rawQuery(sql, [
        AppDateUtils.formatForDatabase(futureDate),
      ]);
    } catch (e) {
      throw Exception('فشل في تحميل المنتجات المستحقة قريباً: $e');
    }
  }

  // Get completed products
  Future<List<ProductModel>> getCompletedProducts({int? customerId}) async {
    try {
      String whereClause = '${DatabaseConstants.productsIsCompleted} = 1';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause += ' AND ${DatabaseConstants.productsCustomerId} = ?';
        whereArgs.add(customerId);
      }

      final results = await _databaseHelper.query(
        DatabaseConstants.productsTable,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: '${DatabaseConstants.productsSaleDate} DESC',
      );

      return results.map((json) => ProductModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل المنتجات المكتملة: $e');
    }
  }

  // Get active products (not completed)
  Future<List<ProductModel>> getActiveProducts({int? customerId}) async {
    try {
      String whereClause = '${DatabaseConstants.productsIsCompleted} = 0';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause += ' AND ${DatabaseConstants.productsCustomerId} = ?';
        whereArgs.add(customerId);
      }

      final results = await _databaseHelper.query(
        DatabaseConstants.productsTable,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: '${DatabaseConstants.productsSaleDate} DESC',
      );

      return results.map((json) => ProductModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل المنتجات النشطة: $e');
    }
  }

  // Get product statistics
  Future<Map<String, dynamic>> getProductStatistics({int? customerId}) async {
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause = 'WHERE ${DatabaseConstants.productsCustomerId} = ?';
        whereArgs.add(customerId);
      }

      final sql =
          '''
        SELECT 
          COUNT(*) as total_products,
          COUNT(CASE WHEN ${DatabaseConstants.productsIsCompleted} = 1 THEN 1 END) as completed_products,
          COUNT(CASE WHEN ${DatabaseConstants.productsIsCompleted} = 0 THEN 1 END) as active_products,
          SUM(${DatabaseConstants.productsOriginalPrice}) as total_original_price,
          SUM(${DatabaseConstants.productsFinalPrice}) as total_final_price,
          SUM(${DatabaseConstants.productsTotalPaid}) as total_paid,
          SUM(${DatabaseConstants.productsFinalPrice} - ${DatabaseConstants.productsTotalPaid}) as total_remaining,
          SUM(${DatabaseConstants.productsFinalPrice} - ${DatabaseConstants.productsOriginalPrice}) as total_profit
        FROM ${DatabaseConstants.productsTable}
        $whereClause
      ''';

      final result = await _databaseHelper.rawQuery(sql, whereArgs);

      if (result.isNotEmpty) {
        return result.first;
      }

      return {
        'total_products': 0,
        'completed_products': 0,
        'active_products': 0,
        'total_original_price': 0.0,
        'total_final_price': 0.0,
        'total_paid': 0.0,
        'total_remaining': 0.0,
        'total_profit': 0.0,
      };
    } catch (e) {
      throw Exception('فشل في تحميل إحصائيات المنتجات: $e');
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(
    String query, {
    int? customerId,
  }) async {
    try {
      if (query.isEmpty) {
        return customerId != null
            ? await getProductsByCustomerId(customerId)
            : await getAllProducts();
      }

      String additionalWhere = '';
      List<dynamic> additionalWhereArgs = [];

      if (customerId != null) {
        additionalWhere = '${DatabaseConstants.productsCustomerId} = ?';
        additionalWhereArgs.add(customerId);
      }

      final results = await _databaseHelper.search(
        DatabaseConstants.productsTable,
        [DatabaseConstants.productsName, DatabaseConstants.productsDetails],
        query,
        additionalWhere: additionalWhere,
        additionalWhereArgs: additionalWhereArgs,
        orderBy: '${DatabaseConstants.productsSaleDate} DESC',
      );

      return results.map((json) => ProductModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في البحث عن المنتجات: $e');
    }
  }

  // Get products count
  Future<int> getProductsCount({int? customerId}) async {
    try {
      if (customerId != null) {
        return await _databaseHelper.count(
          DatabaseConstants.productsTable,
          where: '${DatabaseConstants.productsCustomerId} = ?',
          whereArgs: [customerId],
        );
      }

      return await _databaseHelper.count(DatabaseConstants.productsTable);
    } catch (e) {
      throw Exception('فشل في عد المنتجات: $e');
    }
  }

  // Check if product exists
  Future<bool> productExists(int productId) async {
    try {
      final product = await getProductById(productId);
      return product != null;
    } catch (e) {
      return false;
    }
  }

  // Get recent products
  Future<List<ProductModel>> getRecentProducts({int limit = 10}) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.productsTable,
        orderBy: '${DatabaseConstants.productsCreatedDate} DESC',
        limit: limit,
      );

      return results.map((json) => ProductModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('فشل في تحميل المنتجات الحديثة: $e');
    }
  }

  // Export products data
  Future<List<Map<String, dynamic>>> exportProductsData({
    int? customerId,
  }) async {
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (customerId != null) {
        whereClause = '${DatabaseConstants.productsCustomerId} = ?';
        whereArgs.add(customerId);
      }

      return await _databaseHelper.query(
        DatabaseConstants.productsTable,
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: '${DatabaseConstants.productsSaleDate} DESC',
      );
    } catch (e) {
      throw Exception('فشل في تصدير بيانات المنتجات: $e');
    }
  }
}

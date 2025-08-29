import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/models/product_model.dart';
import '../../data/products_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository _productsRepository;

  ProductsCubit({required ProductsRepository productsRepository})
      : _productsRepository = productsRepository,
        super(const ProductsInitial());

  // Load all products
  Future<void> loadProducts() async {
    try {
      emit(const ProductsLoading());
      final products = await _productsRepository.getAllProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Get product by ID
  Future<void> getProduct(int id) async {
    try {
      emit(const ProductsLoading());
      final product = await _productsRepository.getProductById(id);
      if (product != null) {
        emit(ProductLoaded(product: product));
      } else {
        emit(const ProductsError(message: 'المنتج غير موجود'));
      }
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Add product
  Future<void> addProduct(ProductModel product) async {
    try {
      emit(const ProductsLoading());
      final productId = await _productsRepository.createProduct(product);
      if (productId != null) {
        await loadProducts();
      } else {
        emit(const ProductsError(message: 'فشل في إضافة المنتج'));
      }
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      emit(const ProductsLoading());
      final success = await _productsRepository.updateProduct(product);
      if (success) {
        await loadProducts();
      } else {
        emit(const ProductsError(message: 'فشل في تحديث المنتج'));
      }
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    try {
      emit(const ProductsLoading());
      final success = await _productsRepository.deleteProduct(id);
      if (success) {
        await loadProducts();
      } else {
        emit(const ProductsError(message: 'فشل في حذف المنتج'));
      }
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Get products by customer
  Future<void> getProductsByCustomer(int customerId) async {
    try {
      emit(const ProductsLoading());
      final products = await _productsRepository.getProductsByCustomerId(customerId);
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Get active products
  Future<void> getActiveProducts() async {
    try {
      emit(const ProductsLoading());
      final products = await _productsRepository.getActiveProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Get completed products
  Future<void> getCompletedProducts() async {
    try {
      emit(const ProductsLoading());
      final products = await _productsRepository.getCompletedProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    try {
      emit(const ProductsLoading());
      final products = await _productsRepository.searchProducts(query);
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Get products statistics
  Future<void> getProductsStatistics() async {
    try {
      emit(const ProductsLoading());
      final stats = await _productsRepository.getProductsStatistics();
      emit(ProductsStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Get products with payment details
  Future<void> getProductsWithPaymentDetails() async {
    try {
      emit(const ProductsLoading());
      final products = await _productsRepository.getProductsWithPaymentDetails();
      emit(ProductsWithPaymentDetailsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Get overdue products
  Future<void> getOverdueProducts() async {
    try {
      emit(const ProductsLoading());
      final products = await _productsRepository.getOverdueProducts();
      emit(OverdueProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Update product completion status
  Future<void> updateProductCompletionStatus(int productId, bool isCompleted) async {
    try {
      emit(const ProductsLoading());
      final success = await _productsRepository.updateProductCompletionStatus(productId, isCompleted);
      if (success) {
        await loadProducts();
      } else {
        emit(const ProductsError(message: 'فشل في تحديث حالة المنتج'));
      }
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Export products
  Future<void> exportProducts() async {
    try {
      emit(const ProductsLoading());
      final exportData = await _productsRepository.exportProducts();
      emit(ProductsExported(data: exportData));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Import products
  Future<void> importProducts(List<Map<String, dynamic>> data) async {
    try {
      emit(const ProductsLoading());
      final result = await _productsRepository.importProducts(data);
      emit(ProductsImported(
        importedCount: result['imported'],
        skippedCount: result['skipped'],
        errorCount: result['errors'],
      ));
      // Reload products after import
      await loadProducts();
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Validate product
  Future<void> validateProduct(ProductModel product) async {
    try {
      emit(const ProductsLoading());
      final validation = await _productsRepository.validateProduct(product);
      emit(ProductValidated(
        isValid: validation['isValid'],
        errors: validation['errors'],
      ));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  // Clear state
  void clearState() {
    emit(const ProductsInitial());
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/models/customer_model.dart';
import '../../data/customers_repository.dart';

part 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepository _customersRepository;

  CustomersCubit({required CustomersRepository customersRepository})
      : _customersRepository = customersRepository,
        super(const CustomersInitial());

  // Load all customers
  Future<void> loadCustomers() async {
    try {
      emit(const CustomersLoading());
      final customers = await _customersRepository.getAllCustomers();
      emit(CustomersLoaded(customers: customers));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Get customer by ID
  Future<void> getCustomer(int id) async {
    try {
      emit(const CustomersLoading());
      final customer = await _customersRepository.getCustomerById(id);
      if (customer != null) {
        emit(CustomerLoaded(customer: customer));
      } else {
        emit(const CustomersError(message: 'العميل غير موجود'));
      }
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Add customer
  Future<void> addCustomer(CustomerModel customer) async {
    try {
      emit(const CustomersLoading());
      final customerId = await _customersRepository.createCustomer(customer);
      if (customerId != null) {
        await loadCustomers();
      } else {
        emit(const CustomersError(message: 'فشل في إضافة العميل'));
      }
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Update customer
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      emit(const CustomersLoading());
      final success = await _customersRepository.updateCustomer(customer);
      if (success) {
        await loadCustomers();
      } else {
        emit(const CustomersError(message: 'فشل في تحديث العميل'));
      }
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Delete customer
  Future<void> deleteCustomer(int id) async {
    try {
      emit(const CustomersLoading());
      final success = await _customersRepository.deleteCustomer(id);
      if (success) {
        await loadCustomers();
      } else {
        emit(const CustomersError(message: 'فشل في حذف العميل'));
      }
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Search customers
  Future<void> searchCustomers(String query) async {
    try {
      emit(const CustomersLoading());
      final customers = await _customersRepository.searchCustomers(query);
      emit(CustomersLoaded(customers: customers));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Get customers statistics
  Future<void> getCustomersStatistics() async {
    try {
      emit(const CustomersLoading());
      final stats = await _customersRepository.getCustomersStatistics();
      emit(CustomersStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Get customers with products
  Future<void> getCustomersWithProducts() async {
    try {
      emit(const CustomersLoading());
      final customers = await _customersRepository.getCustomersWithProducts();
      emit(CustomersWithProductsLoaded(customers: customers));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Get customers with overdue payments
  Future<void> getCustomersWithOverduePayments() async {
    try {
      emit(const CustomersLoading());
      final customers = await _customersRepository.getCustomersWithOverduePayments();
      emit(CustomersWithOverdueLoaded(customers: customers));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Export customers
  Future<void> exportCustomers() async {
    try {
      emit(const CustomersLoading());
      final exportData = await _customersRepository.exportCustomers();
      emit(CustomersExported(data: exportData));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Import customers
  Future<void> importCustomers(List<Map<String, dynamic>> data) async {
    try {
      emit(const CustomersLoading());
      final result = await _customersRepository.importCustomers(data);
      emit(CustomersImported(
        importedCount: result['imported'],
        skippedCount: result['skipped'],
        errorCount: result['errors'],
      ));
      // Reload customers after import
      await loadCustomers();
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Validate customer
  Future<void> validateCustomer(CustomerModel customer) async {
    try {
      emit(const CustomersLoading());
      final validation = await _customersRepository.validateCustomer(customer);
      emit(CustomerValidated(
        isValid: validation['isValid'],
        errors: validation['errors'],
      ));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }

  // Clear state
  void clearState() {
    emit(const CustomersInitial());
  }
}

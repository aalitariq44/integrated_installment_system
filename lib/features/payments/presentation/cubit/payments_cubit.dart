import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/models/payment_model.dart';
import '../../data/payments_repository.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final PaymentsRepository _paymentsRepository;

  PaymentsCubit({required PaymentsRepository paymentsRepository})
    : _paymentsRepository = paymentsRepository,
      super(const PaymentsInitial());

  // Load all payments
  Future<void> loadPayments() async {
    try {
      emit(const PaymentsLoading());
      final payments = await _paymentsRepository.getAllPayments();
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Get payment by ID
  Future<void> getPayment(int id) async {
    try {
      emit(const PaymentsLoading());
      final payment = await _paymentsRepository.getPaymentById(id);
      if (payment != null) {
        emit(PaymentLoaded(payment: payment));
      } else {
        emit(const PaymentsError(message: 'الدفعة غير موجودة'));
      }
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Add payment
  Future<void> addPayment(PaymentModel payment) async {
    try {
      emit(const PaymentsLoading());
      final result = await _paymentsRepository.processPayment(payment);
      if (result['success']) {
        emit(
          PaymentProcessed(
            receiptNumber: result['receiptNumber'],
            isCompleted: result['isCompleted'],
          ),
        );
        // Reload payments after processing
        await loadPayments();
      } else {
        emit(PaymentsError(message: result['error'] ?? 'فشل في معالجة الدفعة'));
      }
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Update payment
  Future<void> updatePayment(PaymentModel payment) async {
    try {
      emit(const PaymentsLoading());
      final success = await _paymentsRepository.updatePayment(payment);
      if (success) {
        await loadPayments();
      } else {
        emit(const PaymentsError(message: 'فشل في تحديث الدفعة'));
      }
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Delete payment
  Future<void> deletePayment(int id) async {
    try {
      emit(const PaymentsLoading());
      final success = await _paymentsRepository.deletePayment(id);
      if (success) {
        await loadPayments();
      } else {
        emit(const PaymentsError(message: 'فشل في حذف الدفعة'));
      }
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Get payments by customer
  Future<void> getPaymentsByCustomer(int customerId) async {
    try {
      emit(const PaymentsLoading());
      final payments = await _paymentsRepository.getPaymentsByCustomerId(
        customerId,
      );
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Get payments by product
  Future<void> getPaymentsByProduct(int productId) async {
    try {
      emit(const PaymentsLoading());
      final payments = await _paymentsRepository.getPaymentsByProductId(
        productId,
      );
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Get payments by date range
  Future<void> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      emit(const PaymentsLoading());
      final payments = await _paymentsRepository.getPaymentsByDateRange(
        startDate,
        endDate,
      );
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Search payments
  Future<void> searchPayments(String query) async {
    try {
      emit(const PaymentsLoading());
      final payments = await _paymentsRepository.searchPayments(query);
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Get payments statistics
  Future<void> getPaymentsStatistics() async {
    try {
      emit(const PaymentsLoading());
      final stats = await _paymentsRepository.getPaymentsStatistics();
      emit(PaymentsStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Get payments with details
  Future<void> getPaymentsWithDetails() async {
    try {
      emit(const PaymentsLoading());
      final payments = await _paymentsRepository.getPaymentsWithDetails();
      emit(PaymentsWithDetailsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Get overdue payments
  Future<void> getOverduePayments() async {
    try {
      emit(const PaymentsLoading());
      final payments = await _paymentsRepository.getOverduePayments();
      emit(OverduePaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Get recent payments
  Future<void> getRecentPayments({int limit = 50}) async {
    try {
      emit(const PaymentsLoading());
      final payments = await _paymentsRepository.getRecentPayments(
        limit: limit,
      );
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Generate receipt
  Future<void> generateReceipt(int paymentId) async {
    try {
      emit(const PaymentsLoading());
      final receiptData = await _paymentsRepository.generatePaymentReceipt(
        paymentId,
      );
      if (receiptData != null) {
        emit(ReceiptGenerated(receiptData: receiptData));
      } else {
        emit(const PaymentsError(message: 'فشل في توليد الإيصال'));
      }
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Calculate payment schedule
  Future<void> calculatePaymentSchedule({
    required int productId,
    required double monthlyPayment,
    required DateTime startDate,
  }) async {
    try {
      emit(const PaymentsLoading());
      final schedule = await _paymentsRepository.calculatePaymentSchedule(
        productId,
        monthlyPayment,
        startDate,
      );
      emit(PaymentScheduleCalculated(schedule: schedule));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Export payments
  Future<void> exportPayments() async {
    try {
      emit(const PaymentsLoading());
      final exportData = await _paymentsRepository.exportPayments();
      emit(PaymentsExported(data: exportData));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Import payments
  Future<void> importPayments(List<Map<String, dynamic>> data) async {
    try {
      emit(const PaymentsLoading());
      final result = await _paymentsRepository.importPayments(data);
      emit(
        PaymentsImported(
          importedCount: result['imported'],
          skippedCount: result['skipped'],
          errorCount: result['errors'],
        ),
      );
      // Reload payments after import
      await loadPayments();
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Validate payment
  Future<void> validatePayment(PaymentModel payment) async {
    try {
      emit(const PaymentsLoading());
      final validation = await _paymentsRepository.validatePayment(payment);
      emit(
        PaymentValidated(
          isValid: validation['isValid'],
          errors: validation['errors'],
        ),
      );
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }

  // Clear state
  void clearState() {
    emit(const PaymentsInitial());
  }
}

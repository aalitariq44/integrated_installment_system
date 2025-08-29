import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../data/payments_repository.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final PaymentsRepository paymentsRepository;

  PaymentsCubit({required this.paymentsRepository})
    : super(const PaymentsInitial());

  Future<void> loadPayments() async {
    try {
      emit(const PaymentsLoading());
      // Add your payments loading logic here
      final payments = <dynamic>[]; // Replace with actual repository call
      emit(PaymentsLoaded(payments: payments));
    } catch (e) {
      emit(PaymentsError(message: e.toString()));
    }
  }
}

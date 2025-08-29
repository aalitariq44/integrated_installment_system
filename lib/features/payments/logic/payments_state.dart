part of 'payments_cubit.dart';

@immutable
abstract class PaymentsState {
  const PaymentsState();
}

class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

class PaymentsLoaded extends PaymentsState {
  final List<dynamic> payments; // Replace with proper Payment model

  const PaymentsLoaded({required this.payments});
}

class PaymentsError extends PaymentsState {
  final String message;

  const PaymentsError({required this.message});
}

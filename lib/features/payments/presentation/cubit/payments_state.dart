part of 'payments_cubit.dart';

abstract class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

class PaymentsLoaded extends PaymentsState {
  final List<PaymentModel> payments;

  const PaymentsLoaded({required this.payments});

  @override
  List<Object?> get props => [payments];
}

class PaymentLoaded extends PaymentsState {
  final PaymentModel payment;

  const PaymentLoaded({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentProcessed extends PaymentsState {
  final String receiptNumber;
  final bool isCompleted;

  const PaymentProcessed({
    required this.receiptNumber,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [receiptNumber, isCompleted];
}

class PaymentsStatisticsLoaded extends PaymentsState {
  final Map<String, dynamic> statistics;

  const PaymentsStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class PaymentsWithDetailsLoaded extends PaymentsState {
  final List<Map<String, dynamic>> payments;

  const PaymentsWithDetailsLoaded({required this.payments});

  @override
  List<Object?> get props => [payments];
}

class OverduePaymentsLoaded extends PaymentsState {
  final List<Map<String, dynamic>> payments;

  const OverduePaymentsLoaded({required this.payments});

  @override
  List<Object?> get props => [payments];
}

class ReceiptGenerated extends PaymentsState {
  final Map<String, dynamic> receiptData;

  const ReceiptGenerated({required this.receiptData});

  @override
  List<Object?> get props => [receiptData];
}

class PaymentScheduleCalculated extends PaymentsState {
  final List<Map<String, dynamic>> schedule;

  const PaymentScheduleCalculated({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class PaymentsExported extends PaymentsState {
  final List<Map<String, dynamic>> data;

  const PaymentsExported({required this.data});

  @override
  List<Object?> get props => [data];
}

class PaymentsImported extends PaymentsState {
  final int importedCount;
  final int skippedCount;
  final int errorCount;

  const PaymentsImported({
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
  });

  @override
  List<Object?> get props => [importedCount, skippedCount, errorCount];
}

class PaymentValidated extends PaymentsState {
  final bool isValid;
  final List<String> errors;

  const PaymentValidated({
    required this.isValid,
    required this.errors,
  });

  @override
  List<Object?> get props => [isValid, errors];
}

class PaymentsError extends PaymentsState {
  final String message;

  const PaymentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

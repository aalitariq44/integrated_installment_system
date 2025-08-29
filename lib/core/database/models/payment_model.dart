import 'package:equatable/equatable.dart';
import '../../constants/database_constants.dart';

class PaymentModel extends Equatable {
  final int? paymentId;
  final int productId;
  final int customerId;
  final double paymentAmount;
  final DateTime? paymentDate;
  final DateTime? nextDueDate;
  final String? notes;
  final String? receiptNumber;
  final DateTime? createdDate;

  const PaymentModel({
    this.paymentId,
    required this.productId,
    required this.customerId,
    required this.paymentAmount,
    this.paymentDate,
    this.nextDueDate,
    this.notes,
    this.receiptNumber,
    this.createdDate,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      paymentId: map[DatabaseConstants.paymentsId] as int?,
      productId: map[DatabaseConstants.paymentsProductId] as int,
      customerId: map[DatabaseConstants.paymentsCustomerId] as int,
      paymentAmount: (map[DatabaseConstants.paymentsAmount] as num).toDouble(),
      paymentDate: map[DatabaseConstants.paymentsDate] != null
          ? DateTime.parse(map[DatabaseConstants.paymentsDate] as String)
          : null,
      nextDueDate: map[DatabaseConstants.paymentsNextDueDate] != null
          ? DateTime.parse(map[DatabaseConstants.paymentsNextDueDate] as String)
          : null,
      notes: map[DatabaseConstants.paymentsNotes] as String?,
      receiptNumber: map[DatabaseConstants.paymentsReceiptNumber] as String?,
      createdDate: map[DatabaseConstants.paymentsCreatedDate] != null
          ? DateTime.parse(map[DatabaseConstants.paymentsCreatedDate] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (paymentId != null) DatabaseConstants.paymentsId: paymentId,
      DatabaseConstants.paymentsProductId: productId,
      DatabaseConstants.paymentsCustomerId: customerId,
      DatabaseConstants.paymentsAmount: paymentAmount,
      if (paymentDate != null)
        DatabaseConstants.paymentsDate: paymentDate!.toIso8601String(),
      if (nextDueDate != null)
        DatabaseConstants.paymentsNextDueDate: nextDueDate!.toIso8601String(),
      DatabaseConstants.paymentsNotes: notes,
      DatabaseConstants.paymentsReceiptNumber: receiptNumber,
      if (createdDate != null)
        DatabaseConstants.paymentsCreatedDate: createdDate!.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    int? paymentId,
    int? productId,
    int? customerId,
    double? paymentAmount,
    DateTime? paymentDate,
    DateTime? nextDueDate,
    String? notes,
    String? receiptNumber,
    DateTime? createdDate,
  }) {
    return PaymentModel(
      paymentId: paymentId ?? this.paymentId,
      productId: productId ?? this.productId,
      customerId: customerId ?? this.customerId,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      notes: notes ?? this.notes,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  List<Object?> get props => [
        paymentId,
        productId,
        customerId,
        paymentAmount,
        paymentDate,
        nextDueDate,
        notes,
        receiptNumber,
        createdDate,
      ];

  @override
  String toString() {
    return 'PaymentModel(paymentId: $paymentId, productId: $productId, paymentAmount: $paymentAmount, paymentDate: $paymentDate)';
  }
}

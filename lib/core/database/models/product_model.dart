import 'package:equatable/equatable.dart';
import '../../constants/database_constants.dart';

class ProductModel extends Equatable {
  final int? productId;
  final int customerId;
  final String productName;
  final String? details;
  final double originalPrice;
  final double finalPrice;
  final int paymentIntervalDays;
  final DateTime? saleDate;
  final String? notes;
  final double totalPaid;
  final double? remainingAmount;
  final bool isCompleted;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  const ProductModel({
    this.productId,
    required this.customerId,
    required this.productName,
    this.details,
    required this.originalPrice,
    required this.finalPrice,
    required this.paymentIntervalDays,
    this.saleDate,
    this.notes,
    this.totalPaid = 0.0,
    this.remainingAmount,
    this.isCompleted = false,
    this.createdDate,
    this.updatedDate,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map[DatabaseConstants.productsId] as int?,
      customerId: map[DatabaseConstants.productsCustomerId] as int,
      productName: map[DatabaseConstants.productsName] as String,
      details: map[DatabaseConstants.productsDetails] as String?,
      originalPrice: (map[DatabaseConstants.productsOriginalPrice] as num).toDouble(),
      finalPrice: (map[DatabaseConstants.productsFinalPrice] as num).toDouble(),
      paymentIntervalDays: map[DatabaseConstants.productsPaymentInterval] as int,
      saleDate: map[DatabaseConstants.productsSaleDate] != null
          ? DateTime.parse(map[DatabaseConstants.productsSaleDate] as String)
          : null,
      notes: map[DatabaseConstants.productsNotes] as String?,
      totalPaid: (map[DatabaseConstants.productsTotalPaid] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (map[DatabaseConstants.productsRemainingAmount] as num?)?.toDouble(),
      isCompleted: (map[DatabaseConstants.productsIsCompleted] as int?) == 1,
      createdDate: map[DatabaseConstants.productsCreatedDate] != null
          ? DateTime.parse(map[DatabaseConstants.productsCreatedDate] as String)
          : null,
      updatedDate: map[DatabaseConstants.productsUpdatedDate] != null
          ? DateTime.parse(map[DatabaseConstants.productsUpdatedDate] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (productId != null) DatabaseConstants.productsId: productId,
      DatabaseConstants.productsCustomerId: customerId,
      DatabaseConstants.productsName: productName,
      DatabaseConstants.productsDetails: details,
      DatabaseConstants.productsOriginalPrice: originalPrice,
      DatabaseConstants.productsFinalPrice: finalPrice,
      DatabaseConstants.productsPaymentInterval: paymentIntervalDays,
      if (saleDate != null)
        DatabaseConstants.productsSaleDate: saleDate!.toIso8601String(),
      DatabaseConstants.productsNotes: notes,
      DatabaseConstants.productsTotalPaid: totalPaid,
      DatabaseConstants.productsRemainingAmount: remainingAmount,
      DatabaseConstants.productsIsCompleted: isCompleted ? 1 : 0,
      if (createdDate != null)
        DatabaseConstants.productsCreatedDate: createdDate!.toIso8601String(),
      if (updatedDate != null)
        DatabaseConstants.productsUpdatedDate: updatedDate!.toIso8601String(),
    };
  }

  ProductModel copyWith({
    int? productId,
    int? customerId,
    String? productName,
    String? details,
    double? originalPrice,
    double? finalPrice,
    int? paymentIntervalDays,
    DateTime? saleDate,
    String? notes,
    double? totalPaid,
    double? remainingAmount,
    bool? isCompleted,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      customerId: customerId ?? this.customerId,
      productName: productName ?? this.productName,
      details: details ?? this.details,
      originalPrice: originalPrice ?? this.originalPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      paymentIntervalDays: paymentIntervalDays ?? this.paymentIntervalDays,
      saleDate: saleDate ?? this.saleDate,
      notes: notes ?? this.notes,
      totalPaid: totalPaid ?? this.totalPaid,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  // Calculated properties
  double get profit => finalPrice - originalPrice;
  double get profitPercentage => originalPrice > 0 ? (profit / originalPrice) * 100 : 0;
  double get remainingBalance => finalPrice - totalPaid;
  double get paymentProgress => finalPrice > 0 ? (totalPaid / finalPrice) * 100 : 0;

  @override
  List<Object?> get props => [
        productId,
        customerId,
        productName,
        details,
        originalPrice,
        finalPrice,
        paymentIntervalDays,
        saleDate,
        notes,
        totalPaid,
        remainingAmount,
        isCompleted,
        createdDate,
        updatedDate,
      ];

  @override
  String toString() {
    return 'ProductModel(productId: $productId, productName: $productName, finalPrice: $finalPrice, totalPaid: $totalPaid)';
  }
}

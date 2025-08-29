import 'package:equatable/equatable.dart';
import '../../constants/database_constants.dart';

class CustomerModel extends Equatable {
  final int? customerId;
  final String customerName;
  final String? phoneNumber;
  final String? address;
  final String? notes;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  const CustomerModel({
    this.customerId,
    required this.customerName,
    this.phoneNumber,
    this.address,
    this.notes,
    this.createdDate,
    this.updatedDate,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      customerId: map[DatabaseConstants.customersId] as int?,
      customerName: map[DatabaseConstants.customersName] as String,
      phoneNumber: map[DatabaseConstants.customersPhone] as String?,
      address: map[DatabaseConstants.customersAddress] as String?,
      notes: map[DatabaseConstants.customersNotes] as String?,
      createdDate: map[DatabaseConstants.customersCreatedDate] != null
          ? DateTime.parse(map[DatabaseConstants.customersCreatedDate] as String)
          : null,
      updatedDate: map[DatabaseConstants.customersUpdatedDate] != null
          ? DateTime.parse(map[DatabaseConstants.customersUpdatedDate] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (customerId != null) DatabaseConstants.customersId: customerId,
      DatabaseConstants.customersName: customerName,
      DatabaseConstants.customersPhone: phoneNumber,
      DatabaseConstants.customersAddress: address,
      DatabaseConstants.customersNotes: notes,
      if (createdDate != null)
        DatabaseConstants.customersCreatedDate: createdDate!.toIso8601String(),
      if (updatedDate != null)
        DatabaseConstants.customersUpdatedDate: updatedDate!.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    int? customerId,
    String? customerName,
    String? phoneNumber,
    String? address,
    String? notes,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        phoneNumber,
        address,
        notes,
        createdDate,
        updatedDate,
      ];

  @override
  String toString() {
    return 'CustomerModel(customerId: $customerId, customerName: $customerName, phoneNumber: $phoneNumber)';
  }
}

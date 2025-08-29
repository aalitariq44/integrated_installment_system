import 'package:equatable/equatable.dart';
import '../../constants/database_constants.dart';

class SettingsModel extends Equatable {
  final int? id;
  final String appPassword;
  final String? businessName;
  final String? ownerName;
  final String? phone;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  const SettingsModel({
    this.id,
    required this.appPassword,
    this.businessName,
    this.ownerName,
    this.phone,
    this.createdDate,
    this.updatedDate,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map[DatabaseConstants.settingsId] as int?,
      appPassword: map[DatabaseConstants.settingsAppPassword] as String,
      businessName: map[DatabaseConstants.settingsBusinessName] as String?,
      ownerName: map[DatabaseConstants.settingsOwnerName] as String?,
      phone: map[DatabaseConstants.settingsPhone] as String?,
      createdDate: map[DatabaseConstants.settingsCreatedDate] != null
          ? DateTime.parse(map[DatabaseConstants.settingsCreatedDate] as String)
          : null,
      updatedDate: map[DatabaseConstants.settingsUpdatedDate] != null
          ? DateTime.parse(map[DatabaseConstants.settingsUpdatedDate] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.settingsId: id,
      DatabaseConstants.settingsAppPassword: appPassword,
      DatabaseConstants.settingsBusinessName: businessName,
      DatabaseConstants.settingsOwnerName: ownerName,
      DatabaseConstants.settingsPhone: phone,
      if (createdDate != null)
        DatabaseConstants.settingsCreatedDate: createdDate!.toIso8601String(),
      if (updatedDate != null)
        DatabaseConstants.settingsUpdatedDate: updatedDate!.toIso8601String(),
    };
  }

  SettingsModel copyWith({
    int? id,
    String? appPassword,
    String? businessName,
    String? ownerName,
    String? phone,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      appPassword: appPassword ?? this.appPassword,
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appPassword,
        businessName,
        ownerName,
        phone,
        createdDate,
        updatedDate,
      ];
}

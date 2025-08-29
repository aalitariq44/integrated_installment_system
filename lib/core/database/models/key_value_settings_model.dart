import 'package:equatable/equatable.dart';
import '../../constants/database_constants.dart';

class KeyValueSettingsModel extends Equatable {
  final int? id;
  final String key;
  final String value;
  final String? description;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  const KeyValueSettingsModel({
    this.id,
    required this.key,
    required this.value,
    this.description,
    this.createdDate,
    this.updatedDate,
  });

  factory KeyValueSettingsModel.fromMap(Map<String, dynamic> map) {
    return KeyValueSettingsModel(
      id: map['id'] as int?,
      key: map['key'] as String,
      value: map['value'] as String,
      description: map['description'] as String?,
      createdDate: map['created_date'] != null
          ? DateTime.parse(map['created_date'] as String)
          : null,
      updatedDate: map['updated_date'] != null
          ? DateTime.parse(map['updated_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'key': key,
      'value': value,
      'description': description,
      if (createdDate != null) 'created_date': createdDate!.toIso8601String(),
      if (updatedDate != null) 'updated_date': updatedDate!.toIso8601String(),
    };
  }

  KeyValueSettingsModel copyWith({
    int? id,
    String? key,
    String? value,
    String? description,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return KeyValueSettingsModel(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    key,
    value,
    description,
    createdDate,
    updatedDate,
  ];
}

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

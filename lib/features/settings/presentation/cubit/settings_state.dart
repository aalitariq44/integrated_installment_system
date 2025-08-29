part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final List<KeyValueSettingsModel> settings;

  const SettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SettingLoaded extends SettingsState {
  final KeyValueSettingsModel setting;

  const SettingLoaded({required this.setting});

  @override
  List<Object?> get props => [setting];
}

class BusinessSettingsLoaded extends SettingsState {
  final Map<String, String> settings;

  const BusinessSettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class AppPreferencesLoaded extends SettingsState {
  final Map<String, String> preferences;

  const AppPreferencesLoaded({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class BackupSettingsLoaded extends SettingsState {
  final Map<String, String> settings;

  const BackupSettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SettingsExported extends SettingsState {
  final Map<String, dynamic> data;

  const SettingsExported({required this.data});

  @override
  List<Object?> get props => [data];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

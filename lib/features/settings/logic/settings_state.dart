part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final Map<String, dynamic> settings; // Replace with proper Settings model

  const SettingsLoaded({required this.settings});
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});
}

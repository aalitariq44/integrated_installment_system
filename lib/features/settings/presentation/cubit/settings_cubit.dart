import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/models/key_value_settings_model.dart';
import '../../data/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const SettingsInitial());

  // Load all settings
  Future<void> loadSettings() async {
    try {
      emit(const SettingsLoading());
      final settings = await _settingsRepository.getAllSettings();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Get specific setting
  Future<void> getSetting(String key) async {
    try {
      emit(const SettingsLoading());
      final setting = await _settingsRepository.getSetting(key);
      if (setting != null) {
        emit(SettingLoaded(setting: setting));
      } else {
        emit(const SettingsError(message: 'الإعداد غير موجود'));
      }
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Update or create setting
  Future<void> updateSetting(KeyValueSettingsModel setting) async {
    try {
      emit(const SettingsLoading());
      
      final existingSetting = await _settingsRepository.getSetting(setting.key);
      
      if (existingSetting != null) {
        await _settingsRepository.updateSetting(setting);
      } else {
        await _settingsRepository.createSetting(setting);
      }
      
      // Reload settings after update
      await loadSettings();
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Delete setting
  Future<void> deleteSetting(String key) async {
    try {
      emit(const SettingsLoading());
      await _settingsRepository.deleteSetting(key);
      await loadSettings();
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Get business settings
  Future<void> getBusinessSettings() async {
    try {
      emit(const SettingsLoading());
      final businessSettings = await _settingsRepository.getBusinessSettings();
      emit(BusinessSettingsLoaded(settings: businessSettings));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Update business settings
  Future<void> updateBusinessSettings(Map<String, String> settings) async {
    try {
      emit(const SettingsLoading());
      await _settingsRepository.updateBusinessSettings(settings);
      await getBusinessSettings();
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Get app preferences
  Future<void> getAppPreferences() async {
    try {
      emit(const SettingsLoading());
      final preferences = await _settingsRepository.getAppPreferences();
      emit(AppPreferencesLoaded(preferences: preferences));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Update app preferences
  Future<void> updateAppPreferences(Map<String, String> preferences) async {
    try {
      emit(const SettingsLoading());
      await _settingsRepository.updateAppPreferences(preferences);
      await getAppPreferences();
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Get backup settings
  Future<void> getBackupSettings() async {
    try {
      emit(const SettingsLoading());
      final backupSettings = await _settingsRepository.getBackupSettings();
      emit(BackupSettingsLoaded(settings: backupSettings));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Update backup settings
  Future<void> updateBackupSettings(Map<String, String> settings) async {
    try {
      emit(const SettingsLoading());
      await _settingsRepository.updateBackupSettings(settings);
      await getBackupSettings();
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      emit(const SettingsLoading());
      await _settingsRepository.resetToDefaults();
      await loadSettings();
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Export settings
  Future<void> exportSettings() async {
    try {
      emit(const SettingsLoading());
      final exportData = await _settingsRepository.exportSettings();
      emit(SettingsExported(data: exportData));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> data) async {
    try {
      emit(const SettingsLoading());
      await _settingsRepository.importSettings(data);
      await loadSettings();
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  // Clear state
  void clearState() {
    emit(const SettingsInitial());
  }
}

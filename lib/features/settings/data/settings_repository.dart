import '../../../core/database/database_helper.dart';
import '../../../core/database/models/settings_model.dart'
    as core_settings_model;
import '../../../core/database/models/key_value_settings_model.dart';
import '../../../core/constants/database_constants.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SettingsRepository {
  final DatabaseHelper _databaseHelper;

  SettingsRepository({required DatabaseHelper databaseHelper})
    : _databaseHelper = databaseHelper;

  // Get app settings
  Future<core_settings_model.SettingsModel?> getSettings() async {
    try {
      final result = await _databaseHelper.queryFirst(
        DatabaseConstants.settingsTable,
        where: '${DatabaseConstants.settingsId} = ?',
        whereArgs: [1],
      );

      if (result != null) {
        return core_settings_model.SettingsModel.fromMap(result);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في تحميل الإعدادات: $e');
    }
  }

  // Update app password
  Future<bool> updatePassword(String newPassword) async {
    try {
      final now = DateTime.now();
      final updateCount = await _databaseHelper.update(
        DatabaseConstants.settingsTable,
        {
          DatabaseConstants.settingsAppPassword: newPassword,
          DatabaseConstants.settingsUpdatedDate: now.toIso8601String(),
        },
        where: '${DatabaseConstants.settingsId} = ?',
        whereArgs: [1],
      );

      return updateCount > 0;
    } catch (e) {
      throw Exception('فشل في تحديث كلمة المرور: $e');
    }
  }

  // Update business information
  Future<bool> updateBusinessInfo({
    String? businessName,
    String? ownerName,
    String? phone,
  }) async {
    try {
      final now = DateTime.now();
      final updateData = <String, dynamic>{
        DatabaseConstants.settingsUpdatedDate: now.toIso8601String(),
      };

      if (businessName != null) {
        updateData[DatabaseConstants.settingsBusinessName] = businessName;
      }
      if (ownerName != null) {
        updateData[DatabaseConstants.settingsOwnerName] = ownerName;
      }
      if (phone != null) {
        updateData[DatabaseConstants.settingsPhone] = phone;
      }

      final updateCount = await _databaseHelper.update(
        DatabaseConstants.settingsTable,
        updateData,
        where: '${DatabaseConstants.settingsId} = ?',
        whereArgs: [1],
      );

      return updateCount > 0;
    } catch (e) {
      throw Exception('فشل في تحديث معلومات الشركة: $e');
    }
  }

  // Validate password
  Future<bool> validatePassword(String password) async {
    try {
      final settings = await getSettings();
      return settings?.appPassword == password;
    } catch (e) {
      throw Exception('فشل في التحقق من كلمة المرور: $e');
    }
  }

  // Check if settings exist
  Future<bool> hasSettings() async {
    try {
      final settings = await getSettings();
      return settings != null;
    } catch (e) {
      return false;
    }
  }

  // Initialize default settings if not exist
  Future<bool> initializeSettings({String? password}) async {
    try {
      final hasExistingSettings = await hasSettings();
      if (hasExistingSettings) {
        return true;
      }

      final now = DateTime.now();
      final settingsData = {
        DatabaseConstants.settingsId: 1,
        DatabaseConstants.settingsAppPassword: password ?? '123456',
        DatabaseConstants.settingsCreatedDate: now.toIso8601String(),
        DatabaseConstants.settingsUpdatedDate: now.toIso8601String(),
      };

      final insertedId = await _databaseHelper.insert(
        DatabaseConstants.settingsTable,
        settingsData,
      );

      return insertedId > 0;
    } catch (e) {
      throw Exception('فشل في إنشاء الإعدادات الافتراضية: $e');
    }
  }

  // Reset all settings to default
  Future<bool> resetSettings() async {
    try {
      await _databaseHelper.delete(
        DatabaseConstants.settingsTable,
        where: '${DatabaseConstants.settingsId} = ?',
        whereArgs: [1],
      );

      return await initializeSettings();
    } catch (e) {
      throw Exception('فشل في إعادة تعيين الإعدادات: $e');
    }
  }

  // Get business name for receipts
  Future<String> getBusinessNameForReceipts() async {
    try {
      final settings = await getSettings();
      return settings?.businessName ?? 'نظام إدارة الأقساط';
    } catch (e) {
      return 'نظام إدارة الأقساط';
    }
  }

  // Get owner name for receipts
  Future<String> getOwnerNameForReceipts() async {
    try {
      final settings = await getSettings();
      return settings?.ownerName ?? '';
    } catch (e) {
      return '';
    }
  }

  // Get phone for receipts
  Future<String> getPhoneForReceipts() async {
    try {
      final settings = await getSettings();
      return settings?.phone ?? '';
    } catch (e) {
      return '';
    }
  }

  // Get all settings (for compatibility with cubit)
  Future<List<KeyValueSettingsModel>> getAllSettings() async {
    try {
      final settings = await getSettings();
      if (settings == null) {
        return [];
      }

      final List<KeyValueSettingsModel> keyValueSettings = [];

      // Convert SettingsModel fields to KeyValueSettingsModel
      keyValueSettings.add(
        KeyValueSettingsModel(
          key: 'appPassword',
          value: settings.appPassword,
          description: 'كلمة مرور التطبيق',
        ),
      );
      if (settings.businessName != null) {
        keyValueSettings.add(
          KeyValueSettingsModel(
            key: 'businessName',
            value: settings.businessName!,
            description: 'اسم الشركة',
          ),
        );
      }
      if (settings.ownerName != null) {
        keyValueSettings.add(
          KeyValueSettingsModel(
            key: 'ownerName',
            value: settings.ownerName!,
            description: 'اسم المالك',
          ),
        );
      }
      if (settings.phone != null) {
        keyValueSettings.add(
          KeyValueSettingsModel(
            key: 'phone',
            value: settings.phone!,
            description: 'رقم الهاتف',
          ),
        );
      }
      // Add other fields from SettingsModel if necessary

      return keyValueSettings;
    } catch (e) {
      throw Exception('فشل في تحميل جميع الإعدادات: $e');
    }
  }

  // Get single setting by key
  Future<dynamic> getSetting(String key) async {
    try {
      final settings = await getSettings();
      final settingsMap = settings?.toMap() ?? {};
      return settingsMap[key];
    } catch (e) {
      throw Exception('فشل في تحميل الإعداد: $e');
    }
  }

  // Update single setting
  Future<bool> updateSetting(String key, dynamic value) async {
    try {
      final now = DateTime.now();
      final updateCount = await _databaseHelper.update(
        DatabaseConstants.settingsTable,
        {
          key: value,
          DatabaseConstants.settingsUpdatedDate: now.toIso8601String(),
        },
        where: '${DatabaseConstants.settingsId} = ?',
        whereArgs: [1],
      );
      return updateCount > 0;
    } catch (e) {
      throw Exception('فشل في تحديث الإعداد: $e');
    }
  }

  // Create single setting
  Future<bool> createSetting(String key, dynamic value) async {
    // For this app, we only have one settings record, so we update instead
    return await updateSetting(key, value);
  }

  // Delete setting (set to null)
  Future<bool> deleteSetting(String key) async {
    return await updateSetting(key, null);
  }

  // Get business settings
  Future<Map<String, dynamic>> getBusinessSettings() async {
    try {
      final settings = await getSettings();
      return {
        'businessName': settings?.businessName,
        'ownerName': settings?.ownerName,
        'phone': settings?.phone,
      };
    } catch (e) {
      throw Exception('فشل في تحميل إعدادات الشركة: $e');
    }
  }

  // Update business settings
  Future<bool> updateBusinessSettings(
    Map<String, dynamic> businessSettings,
  ) async {
    return await updateBusinessInfo(
      businessName: businessSettings['businessName']?.toString(),
      ownerName: businessSettings['ownerName']?.toString(),
      phone: businessSettings['phone']?.toString(),
    );
  }

  // Get app preferences (placeholder for future features)
  Future<Map<String, dynamic>> getAppPreferences() async {
    return {'theme': 'light', 'language': 'ar', 'notifications': true};
  }

  // Update app preferences
  Future<bool> updateAppPreferences(Map<String, dynamic> preferences) async {
    // For now, just return true as these settings aren't stored in DB yet
    return true;
  }

  // Get backup settings
  Future<Map<String, dynamic>> getBackupSettings() async {
    return {
      'autoBackup': false,
      'backupFrequency': 'daily',
      'cloudBackup': false,
    };
  }

  // Update backup settings
  Future<bool> updateBackupSettings(Map<String, dynamic> backupSettings) async {
    // For now, just return true as these settings aren't stored in DB yet
    return true;
  }

  // Reset to defaults
  Future<bool> resetToDefaults() async {
    return await resetSettings();
  }

  // Export settings
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final settings = await getSettings();
      return settings?.toMap() ?? {};
    } catch (e) {
      throw Exception('فشل في تصدير الإعدادات: $e');
    }
  }

  // Import settings
  Future<bool> importSettings(Map<String, dynamic> settingsData) async {
    try {
      final now = DateTime.now();
      settingsData[DatabaseConstants.settingsUpdatedDate] = now
          .toIso8601String();

      final updateCount = await _databaseHelper.update(
        DatabaseConstants.settingsTable,
        settingsData,
        where: '${DatabaseConstants.settingsId} = ?',
        whereArgs: [1],
      );

      return updateCount > 0;
    } catch (e) {
      throw Exception('فشل في استيراد الإعدادات: $e');
    }
  }

  // Create backup
  Future<void> createBackup() async {
    debugPrint("Backup process started in repository.");

    try {
      debugPrint("Step 1: Getting database path.");
      final dbPath = await _databaseHelper.getDatabasePath();
      print("  - DB Path: $dbPath");

      final dbFile = File(dbPath);

      print("Step 2: Checking for database file existence.");
      final fileExists = await dbFile.exists();
      if (!fileExists) {
        print("  - Error: Database file not found!");
        throw Exception('Database file not found at path: $dbPath');
      }
      print("  - Success: Database file found.");

      print("Step 3: Reading database file.");
      final bytes = await dbFile.readAsBytes();
      print("  - Success: Read ${bytes.lengthInBytes} bytes from file.");

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'backup-$timestamp.db';
      print("Step 4: Preparing to upload. Filename: $fileName");

      final supabase = Supabase.instance.client;
      debugPrint("Step 5: Attempting to upload to Supabase Storage bucket 'Fadak'.");
      debugPrint("  - Bucket: 'Fadak', Filename: '$fileName', Bytes length: ${bytes.lengthInBytes}");
      
      await supabase.storage.from('Fadak').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: false),
          ).timeout(const Duration(seconds: 30), onTimeout: () {
            throw Exception('Supabase upload timed out after 30 seconds.');
          });
      debugPrint("  - Success: Upload completed.");

    } catch (e, stackTrace) {
      debugPrint("---!!! ERROR in backup process !!!---");
      debugPrint("  - Error Type: ${e.runtimeType}");
      debugPrint("  - Error Message: $e");
      debugPrint("  - Stack Trace: $stackTrace");
      rethrow;
    }
  }
}

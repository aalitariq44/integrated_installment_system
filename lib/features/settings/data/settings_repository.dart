import '../../../core/database/database_helper.dart';
import '../../../core/database/models/settings_model.dart';
import '../../../core/constants/database_constants.dart';

class SettingsRepository {
  final DatabaseHelper _databaseHelper;

  SettingsRepository({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  // Get app settings
  Future<SettingsModel?> getSettings() async {
    try {
      final result = await _databaseHelper.queryFirst(
        DatabaseConstants.settingsTable,
        where: '${DatabaseConstants.settingsId} = ?',
        whereArgs: [1],
      );

      if (result != null) {
        return SettingsModel.fromMap(result);
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
}

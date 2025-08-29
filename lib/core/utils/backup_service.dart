import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import '../database/database_helper.dart';

class BackupService {
  final SupabaseClient _supabaseClient;
  final DatabaseHelper _databaseHelper;

  BackupService({
    required SupabaseClient supabaseClient,
    required DatabaseHelper databaseHelper,
  }) : _supabaseClient = supabaseClient,
       _databaseHelper = databaseHelper;

  // Getter للوصول إلى SupabaseClient للاختبار
  SupabaseClient get supabaseClient => _supabaseClient;

  Future<void> uploadDatabaseBackup() async {
    try {
      print('بدء عملية النسخ الاحتياطي...');

      // التحقق من وجود bucket "Fadak"
      print('التحقق من وجود bucket "Fadak"...');
      final buckets = await _supabaseClient.storage.listBuckets();
      buckets.firstWhere(
        (bucket) => bucket.id == 'Fadak',
        orElse: () => throw Exception(
          'Bucket "Fadak" غير موجود في Supabase. يرجى إنشاؤه أولاً.',
        ),
      );
      print('تم العثور على bucket "Fadak"');

      // الحصول على مسار قاعدة البيانات
      final databasePath = await _databaseHelper.getDatabasePath();
      print('مسار قاعدة البيانات: $databasePath');

      final databaseFile = File(databasePath);

      // التحقق من وجود الملف
      if (!await databaseFile.exists()) {
        throw Exception(
          'ملف قاعدة البيانات غير موجود في المسار: $databasePath',
        );
      }

      // الحصول على حجم الملف
      final fileSize = await databaseFile.length();
      print('حجم ملف قاعدة البيانات: ${fileSize} bytes');

      if (fileSize == 0) {
        throw Exception('ملف قاعدة البيانات فارغ');
      }

      print('قراءة محتوى الملف...');
      final bytes = await databaseFile.readAsBytes();
      print('تم قراءة ${bytes.length} bytes');

      final fileName = basename(databasePath);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFileName = 'backup_$timestamp-$fileName';

      print('رفع الملف إلى Supabase: $backupFileName');

      // رفع الملف
      await _supabaseClient.storage
          .from('Fadak')
          .uploadBinary(
            backupFileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // تغيير إلى true للسماح بالاستبدال
              contentType: 'application/octet-stream',
            ),
          );

      print('تم رفع النسخة الاحتياطية بنجاح: $backupFileName');
    } catch (e, stackTrace) {
      print('خطأ في رفع النسخة الاحتياطية: $e');
      print('تفاصيل الخطأ: $stackTrace');
      rethrow;
    }
  }
}

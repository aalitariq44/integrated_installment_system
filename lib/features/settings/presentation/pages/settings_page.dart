import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_helper.dart';
import '../cubit/settings_cubit.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app.dart'; // Corrected import path for app.dart to access scaffoldMessengerKey

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  Future<void> _createBackup() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Use the global key for ScaffoldMessenger
    final scaffoldMessenger = scaffoldMessengerKey.currentState;
    if (scaffoldMessenger == null) {
      debugPrint("Error: scaffoldMessengerKey.currentState is null.");
      return;
    }

    try {
      final settingsCubit = context.read<SettingsCubit>();
      await settingsCubit.createBackup();

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('تم رفع النسخة الاحتياطية بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('خطأ في رفع النسخة الاحتياطية: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تغيير كلمة المرور'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الحالية',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور الحالية';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور الجديدة';
                    }
                    if (value.length < 4) {
                      return 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور الجديدة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور';
                    }
                    if (value != newPasswordController.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final authCubit = context.read<AuthCubit>();
                    await authCubit.changePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                    );

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تغيير كلمة المرور بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    String errorMessage = 'خطأ في تغيير كلمة المرور';
                    if (e is Exception) {
                      errorMessage = e.toString().replaceFirst(
                        'Exception: ',
                        '',
                      );
                    } else {
                      errorMessage = e.toString();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('تغيير'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final authCubit = context.read<AuthCubit>();
                authCubit.logout();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            onPressed: _isLoading ? null : _createBackup,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // معلومات التطبيق
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            const Text(
                              'معلومات التطبيق',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('اسم التطبيق: نظام إدارة الأقساط المتكامل'),
                        const SizedBox(height: 8),
                        const Text('الإصدار: 1.0.0'),
                        const SizedBox(height: 8),
                        const Text('تطوير: نظام محلي'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // الأمان
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            const Text(
                              'الأمان',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.lock, color: Colors.orange),
                          title: const Text('تغيير كلمة المرور'),
                          subtitle: const Text(
                            'تحديث كلمة المرور الخاصة بالتطبيق',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _changePassword,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // النسخ الاحتياطي
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.backup, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            const Text(
                              'النسخ الاحتياطي',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.save, color: Colors.green),
                          title: const Text('إنشاء نسخة احتياطية'),
                          subtitle: const Text(
                            'حفظ جميع البيانات في ملف احتياطي',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _createBackup,
                        ),
                        const Divider(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'للاستعادة، تواصل مع المطور وأرسل ملف النسخة الاحتياطية',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // الإحصائيات
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            const Text(
                              'الإحصائيات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<SettingsCubit, SettingsState>(
                          builder: (context, state) {
                            // يمكن إضافة إحصائيات سريعة هنا
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('إجمالي العملاء:'),
                                    FutureBuilder<int>(
                                      future: context
                                          .read<DatabaseHelper>()
                                          .count('customers'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data ?? 0}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('إجمالي المنتجات:'),
                                    FutureBuilder<int>(
                                      future: context
                                          .read<DatabaseHelper>()
                                          .count('products'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data ?? 0}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('إجمالي الدفعات:'),
                                    FutureBuilder<int>(
                                      future: context
                                          .read<DatabaseHelper>()
                                          .count('payments'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data ?? 0}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // تسجيل الخروج
                Card(
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red.shade600),
                    title: Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text('الخروج من التطبيق'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.red.shade600,
                    ),
                    onTap: _logout,
                  ),
                ),
              ],
            ),
    );
  }
}

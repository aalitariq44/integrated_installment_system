import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../settings/data/settings_repository.dart'; // Import SettingsRepository

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // إضافة تأخير للسماح بعرض splash screen
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final settingsRepository = context.read<SettingsRepository>();
      final hasSettings = await settingsRepository.hasSettings();

      if (!mounted) return;

      if (!hasSettings) {
        // If no settings (and thus no password) exist, navigate to setup password page
        Navigator.of(context).pushReplacementNamed(AppRoutes.setupPassword);
      } else {
        // If settings exist, proceed with authentication check
        final authCubit = context.read<AuthCubit>();
        await authCubit.checkAuthStatus();

        if (!mounted) return;

        final authState = authCubit.state;
        if (authState is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      }
    } catch (error) {
      if (!mounted) return;

      // In case of any error, navigate to the login page (or setup if no settings)
      final settingsRepository = context.read<SettingsRepository>();
      final hasSettings = await settingsRepository.hasSettings();
      if (!hasSettings) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.setupPassword);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار التطبيق
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // اسم التطبيق
              Text(
                AppConstants.appName,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.sm),

              // وصف التطبيق
              Text(
                'نظام إدارة الأقساط المتكامل',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.surface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.xxl),

              // مؤشر التحميل
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              Text(
                'جاري تحميل التطبيق...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.surface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

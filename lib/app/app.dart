import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/themes/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'routes/route_generator.dart';
import 'routes/app_routes.dart';
import '../features/auth/logic/auth_cubit.dart';
import '../features/customers/logic/customers_cubit.dart';
import '../features/products/logic/products_cubit.dart';
import '../features/payments/logic/payments_cubit.dart';
import '../features/statistics/logic/statistics_cubit.dart';
import '../features/settings/logic/settings_cubit.dart';
import '../features/customers/data/customers_repository.dart';
import '../features/products/data/products_repository.dart';
import '../features/payments/data/payments_repository.dart';
import '../features/statistics/data/statistics_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../core/database/database_helper.dart';

class InstallmentsApp extends StatelessWidget {
  const InstallmentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DatabaseHelper>(
          create: (context) => DatabaseHelper(),
        ),
        RepositoryProvider<CustomersRepository>(
          create: (context) => CustomersRepository(
            databaseHelper: context.read<DatabaseHelper>(),
          ),
        ),
        RepositoryProvider<ProductsRepository>(
          create: (context) => ProductsRepository(
            databaseHelper: context.read<DatabaseHelper>(),
          ),
        ),
        RepositoryProvider<PaymentsRepository>(
          create: (context) => PaymentsRepository(
            databaseHelper: context.read<DatabaseHelper>(),
          ),
        ),
        RepositoryProvider<StatisticsRepository>(
          create: (context) => StatisticsRepository(
            databaseHelper: context.read<DatabaseHelper>(),
          ),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepository(
            databaseHelper: context.read<DatabaseHelper>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              settingsRepository: context.read<SettingsRepository>(),
            ),
          ),
          BlocProvider<CustomersCubit>(
            create: (context) => CustomersCubit(
              customersRepository: context.read<CustomersRepository>(),
            ),
          ),
          BlocProvider<ProductsCubit>(
            create: (context) => ProductsCubit(
              productsRepository: context.read<ProductsRepository>(),
            ),
          ),
          BlocProvider<PaymentsCubit>(
            create: (context) => PaymentsCubit(
              paymentsRepository: context.read<PaymentsRepository>(),
            ),
          ),
          BlocProvider<StatisticsCubit>(
            create: (context) => StatisticsCubit(
              statisticsRepository: context.read<StatisticsRepository>(),
            ),
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(
              settingsRepository: context.read<SettingsRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,

          // Locale configuration for Arabic
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [Locale('ar', 'SA')],

          // Text direction for RTL
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },

          // Navigation
          initialRoute: AppRoutes.splash,
          onGenerateRoute: RouteGenerator.generateRoute,

          // Navigation observer for debugging
          navigatorObservers: [
            // Add analytics or logging observers here if needed
          ],
        ),
      ),
    );
  }
}

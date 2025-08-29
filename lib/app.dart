import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/customers/data/customers_repository.dart';
import 'features/products/data/products_repository.dart';
import 'features/payments/data/payments_repository.dart';
import 'features/statistics/data/statistics_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/customers/presentation/cubit/customers_cubit.dart';
import 'features/products/presentation/cubit/products_cubit.dart';
import 'features/payments/presentation/cubit/payments_cubit.dart';
import 'features/statistics/presentation/cubit/statistics_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/route_generator.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class InstallmentApp extends StatelessWidget {
  const InstallmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DatabaseHelper>(
          create: (context) => DatabaseHelper(),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepository(
            databaseHelper: context.read<DatabaseHelper>(),
          ),
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
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            databaseHelper: context.read<DatabaseHelper>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(
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
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
              settingsRepository: context.read<SettingsRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey, // Assign the global key
          title: 'نظام الأقساط المتكامل',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

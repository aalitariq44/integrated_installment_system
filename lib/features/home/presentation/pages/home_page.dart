import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../statistics/presentation/cubit/statistics_cubit.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when the page loads
    context.read<StatisticsCubit>().getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام الأقساط المتكامل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StatisticsCubit>().refreshStatistics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<StatisticsCubit>().refreshStatistics();
        },
        child: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is StatisticsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ في تحميل البيانات',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StatisticsCubit>().refreshStatistics();
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is DashboardDataLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    const QuickActions(),
                    const SizedBox(height: 24),
                    
                    // Statistics Overview
                    Text(
                      'نظرة عامة',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticsCards(state.data['overall']),
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    Text(
                      'النشاط الحديث',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    RecentActivity(
                      activities: List<Map<String, dynamic>>.from(
                        state.data['recentActivity'] ?? [],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return const Center(
              child: Text('مرحباً بك في نظام الأقساط المتكامل'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add payment
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, dynamic>? stats) {
    if (stats == null) return const SizedBox.shrink();
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        DashboardCard(
          title: 'إجمالي العملاء',
          value: '${stats['total_customers'] ?? 0}',
          icon: Icons.people,
          color: Colors.blue,
        ),
        DashboardCard(
          title: 'المنتجات النشطة',
          value: '${stats['active_products'] ?? 0}',
          icon: Icons.inventory,
          color: Colors.green,
        ),
        DashboardCard(
          title: 'إجمالي المبيعات',
          value: '${(stats['total_sales'] ?? 0.0).toStringAsFixed(0)} ر.س',
          icon: Icons.monetization_on,
          color: Colors.orange,
        ),
        DashboardCard(
          title: 'المبلغ المحصل',
          value: '${(stats['total_collected'] ?? 0.0).toStringAsFixed(0)} ر.س',
          icon: Icons.account_balance_wallet,
          color: Colors.purple,
        ),
      ],
    );
  }
}

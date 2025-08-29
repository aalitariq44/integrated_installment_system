import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/statistics_repository.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository _statisticsRepository;

  StatisticsCubit({required StatisticsRepository statisticsRepository})
      : _statisticsRepository = statisticsRepository,
        super(const StatisticsInitial());

  // Get overall statistics
  Future<void> getOverallStatistics() async {
    try {
      emit(const StatisticsLoading());
      final stats = await _statisticsRepository.getOverallStatistics();
      emit(OverallStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get monthly statistics
  Future<void> getMonthlyStatistics({int? year, int monthsCount = 12}) async {
    try {
      emit(const StatisticsLoading());
      final stats = await _statisticsRepository.getMonthlyStatistics(
        year: year,
        monthsCount: monthsCount,
      );
      emit(MonthlyStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get daily statistics
  Future<void> getDailyStatistics({DateTime? targetMonth}) async {
    try {
      emit(const StatisticsLoading());
      final stats = await _statisticsRepository.getDailyStatistics(
        targetMonth: targetMonth,
      );
      emit(DailyStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get top customers
  Future<void> getTopCustomers({int limit = 10}) async {
    try {
      emit(const StatisticsLoading());
      final customers = await _statisticsRepository.getTopCustomers(limit: limit);
      emit(TopCustomersLoaded(customers: customers));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get payment trends
  Future<void> getPaymentTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      emit(const StatisticsLoading());
      final trends = await _statisticsRepository.getPaymentTrends(
        startDate: startDate,
        endDate: endDate,
      );
      emit(PaymentTrendsLoaded(trends: trends));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get overdue statistics
  Future<void> getOverdueStatistics() async {
    try {
      emit(const StatisticsLoading());
      final stats = await _statisticsRepository.getOverdueStatistics();
      emit(OverdueStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get product categories statistics
  Future<void> getProductCategoriesStatistics() async {
    try {
      emit(const StatisticsLoading());
      final stats = await _statisticsRepository.getProductCategoriesStatistics();
      emit(ProductCategoriesStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get recent activity
  Future<void> getRecentActivity({int limit = 20}) async {
    try {
      emit(const StatisticsLoading());
      final activity = await _statisticsRepository.getRecentActivity(limit: limit);
      emit(RecentActivityLoaded(activity: activity));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get collection efficiency
  Future<void> getCollectionEfficiency() async {
    try {
      emit(const StatisticsLoading());
      final efficiency = await _statisticsRepository.getCollectionEfficiency();
      emit(CollectionEfficiencyLoaded(efficiency: efficiency));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Get comprehensive dashboard data
  Future<void> getDashboardData() async {
    try {
      emit(const StatisticsLoading());

      // Load multiple statistics concurrently
      final results = await Future.wait([
        _statisticsRepository.getOverallStatistics(),
        _statisticsRepository.getMonthlyStatistics(),
        _statisticsRepository.getTopCustomers(limit: 5),
        _statisticsRepository.getOverdueStatistics(),
        _statisticsRepository.getRecentActivity(limit: 10),
        _statisticsRepository.getCollectionEfficiency(),
      ]);

      final dashboardData = {
        'overall': results[0],
        'monthly': results[1],
        'topCustomers': results[2],
        'overdue': results[3],
        'recentActivity': results[4],
        'collectionEfficiency': results[5],
      };

      emit(DashboardDataLoaded(data: dashboardData));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  // Refresh all statistics
  Future<void> refreshStatistics() async {
    await getDashboardData();
  }

  // Clear state
  void clearState() {
    emit(const StatisticsInitial());
  }
}

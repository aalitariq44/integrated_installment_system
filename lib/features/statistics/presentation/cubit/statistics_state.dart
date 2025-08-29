part of 'statistics_cubit.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class OverallStatisticsLoaded extends StatisticsState {
  final Map<String, dynamic> statistics;

  const OverallStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class MonthlyStatisticsLoaded extends StatisticsState {
  final List<Map<String, dynamic>> statistics;

  const MonthlyStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class DailyStatisticsLoaded extends StatisticsState {
  final List<Map<String, dynamic>> statistics;

  const DailyStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class TopCustomersLoaded extends StatisticsState {
  final List<Map<String, dynamic>> customers;

  const TopCustomersLoaded({required this.customers});

  @override
  List<Object?> get props => [customers];
}

class PaymentTrendsLoaded extends StatisticsState {
  final Map<String, dynamic> trends;

  const PaymentTrendsLoaded({required this.trends});

  @override
  List<Object?> get props => [trends];
}

class OverdueStatisticsLoaded extends StatisticsState {
  final Map<String, dynamic> statistics;

  const OverdueStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class ProductCategoriesStatisticsLoaded extends StatisticsState {
  final List<Map<String, dynamic>> statistics;

  const ProductCategoriesStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class RecentActivityLoaded extends StatisticsState {
  final List<Map<String, dynamic>> activity;

  const RecentActivityLoaded({required this.activity});

  @override
  List<Object?> get props => [activity];
}

class CollectionEfficiencyLoaded extends StatisticsState {
  final Map<String, dynamic> efficiency;

  const CollectionEfficiencyLoaded({required this.efficiency});

  @override
  List<Object?> get props => [efficiency];
}

class DashboardDataLoaded extends StatisticsState {
  final Map<String, dynamic> data;

  const DashboardDataLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}

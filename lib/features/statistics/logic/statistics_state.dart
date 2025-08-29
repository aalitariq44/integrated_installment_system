part of 'statistics_cubit.dart';

@immutable
abstract class StatisticsState {
  const StatisticsState();
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final Map<String, dynamic> statistics; // Replace with proper Statistics model

  const StatisticsLoaded({required this.statistics});
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError({required this.message});
}

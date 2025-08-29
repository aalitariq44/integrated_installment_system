import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../data/statistics_repository.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository statisticsRepository;

  StatisticsCubit({required this.statisticsRepository}) : super(const StatisticsInitial());

  Future<void> loadStatistics() async {
    try {
      emit(const StatisticsLoading());
      // Add your statistics loading logic here
      final statistics = <String, dynamic>{}; // Replace with actual repository call
      emit(StatisticsLoaded(statistics: statistics));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }
}

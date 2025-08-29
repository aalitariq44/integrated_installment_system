import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../data/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsCubit({required this.settingsRepository})
    : super(const SettingsInitial());

  Future<void> loadSettings() async {
    try {
      emit(const SettingsLoading());
      // Add your settings loading logic here
      final settings =
          <String, dynamic>{}; // Replace with actual repository call
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }
}

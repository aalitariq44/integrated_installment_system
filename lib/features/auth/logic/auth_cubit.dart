import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../settings/data/settings_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SettingsRepository _settingsRepository;

  AuthCubit({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(const AuthInitial());

  // Check if user is authenticated
  Future<void> checkAuthStatus() async {
    try {
      emit(const AuthLoading());
      final hasSettings = await _settingsRepository.hasSettings();
      if (hasSettings) {
        emit(const AuthAuthenticated());
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Login with password
  Future<void> login(String password) async {
    try {
      emit(const AuthLoading());
      final isValid = await _settingsRepository.validatePassword(password);
      if (isValid) {
        emit(const AuthAuthenticated());
      } else {
        emit(const AuthError(message: 'كلمة المرور غير صحيحة'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Logout
  void logout() {
    emit(const AuthUnauthenticated());
  }

  // Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      emit(const AuthLoading());

      // Validate old password
      final isOldPasswordValid = await _settingsRepository.validatePassword(
        oldPassword,
      );
      if (!isOldPasswordValid) {
        emit(const AuthError(message: 'كلمة المرور الحالية غير صحيحة'));
        return;
      }

      // Update password
      final success = await _settingsRepository.updatePassword(newPassword);
      if (success) {
        emit(const AuthPasswordChanged());
      } else {
        emit(const AuthError(message: 'فشل في تحديث كلمة المرور'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Setup initial password
  Future<void> setupPassword(String password) async {
    try {
      emit(const AuthLoading());
      final success = await _settingsRepository.initializeSettings(
        password: password,
      );
      if (success) {
        emit(const AuthAuthenticated());
      } else {
        emit(const AuthError(message: 'فشل في إعداد كلمة المرور'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}

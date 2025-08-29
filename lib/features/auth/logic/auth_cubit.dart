import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_repository.dart'; // Import AuthRepository
import '../../settings/data/settings_repository.dart'; // Keep SettingsRepository for password management

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SettingsRepository _settingsRepository; // Keep SettingsRepository

  AuthCubit({
    required AuthRepository authRepository,
    required SettingsRepository settingsRepository,
  })  : _authRepository = authRepository,
        _settingsRepository = settingsRepository,
        super(const AuthInitial());

  // Check if user is authenticated
  Future<void> checkAuthStatus() async {
    try {
      emit(const AuthLoading());
      final isAuthenticated = await _authRepository.checkAuthStatus();
      if (isAuthenticated) {
        emit(const AuthAuthenticated());
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Login with username and password
  Future<void> login(String username, String password) async {
    try {
      emit(const AuthLoading());
      await _authRepository.login(username, password);
      emit(const AuthAuthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      emit(const AuthLoading());
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Change password (still uses SettingsRepository as it's a setting)
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

  // Setup initial password (still uses SettingsRepository as it's a setting)
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

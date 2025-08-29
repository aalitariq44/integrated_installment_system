import '../../../core/database/database_helper.dart';
import '../../../core/constants/database_constants.dart';

class AuthRepository {
  final DatabaseHelper databaseHelper;
  bool _isAuthenticatedInSession = false; // New session flag

  AuthRepository({required this.databaseHelper});

  Future<bool> checkAuthStatus() async {
    // Check if a password has been set in the settings
    final settings = await databaseHelper.queryFirst(
      DatabaseConstants.settingsTable,
      columns: [DatabaseConstants.settingsAppPassword],
      where: '${DatabaseConstants.settingsId} = ?',
      whereArgs: [1],
    );

    final bool passwordExists = settings != null &&
        settings[DatabaseConstants.settingsAppPassword] != null &&
        (settings[DatabaseConstants.settingsAppPassword] as String).isNotEmpty;

    // If a password exists, the user is only authenticated if they've logged in this session.
    // If no password exists, the app can proceed without a password prompt (or prompt for setup).
    return !passwordExists || _isAuthenticatedInSession;
  }

  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final settings = await databaseHelper.queryFirst(
      DatabaseConstants.settingsTable,
      columns: [DatabaseConstants.settingsAppPassword],
      where: '${DatabaseConstants.settingsId} = ?',
      whereArgs: [1],
    );

    if (settings != null &&
        settings[DatabaseConstants.settingsAppPassword] == password) {
      _isAuthenticatedInSession = true; // Set session flag on successful login
      return true;
    } else {
      _isAuthenticatedInSession = false; // Ensure flag is false on failed login
      return false;
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    _isAuthenticatedInSession = false; // Clear session flag on logout
    return;
  }
}

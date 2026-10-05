import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../features/auth/domain/user_model.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;

  AuthNotifier(this._storage) : super(AuthState()) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.read(key: StorageKeys.accessToken);
    final roleStr = await _storage.read(key: StorageKeys.userRole);

    if (token != null && roleStr != null) {
      // Mock / cached initial restoration
      final mockUser = User(
        id: 'user_1',
        email: 'user@vayal2veedu.com',
        phone: '+91 9876543210',
        name: 'Vayal 2 Veedu User',
        role: userRoleFromString(roleStr),
      );
      state = state.copyWith(
        user: mockUser,
        isAuthenticated: true,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  Future<bool> login(String email, String password, UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate backend authentication request & response
      await Future.delayed(const Duration(milliseconds: 800));

      final authenticatedUser = User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        phone: '+91 9876543210',
        name: email.split('@').first,
        role: role,
      );

      await _storage.write(key: StorageKeys.accessToken, value: 'mock_jwt_access_token');
      await _storage.write(key: StorageKeys.refreshToken, value: 'mock_jwt_refresh_token');
      await _storage.write(key: StorageKeys.userRole, value: userRoleToString(role));

      state = state.copyWith(
        user: authenticatedUser,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed. Please check your credentials.',
      );
      return false;
    }
  }

  void updateUserProfile({required String name, required String phone, required String email}) {
    if (state.user != null) {
      final updated = User(
        id: state.user!.id,
        email: email,
        phone: phone,
        name: name,
        role: state.user!.role,
        profileImageUrl: state.user!.profileImageUrl,
        isActive: state.user!.isActive,
      );
      state = state.copyWith(user: updated);
    }
  }

  Future<bool> register(String name, String email, String phone, String password, UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final registeredUser = User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        phone: phone,
        name: name,
        role: role,
      );

      await _storage.write(key: StorageKeys.accessToken, value: 'mock_jwt_access_token');
      await _storage.write(key: StorageKeys.userRole, value: userRoleToString(role));

      state = state.copyWith(
        user: registeredUser,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = AuthState();
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});

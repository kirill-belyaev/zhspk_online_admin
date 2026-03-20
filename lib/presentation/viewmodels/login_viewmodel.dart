import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/zhspk_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/zhspk_repository.dart';

// ============ Провайдеры сервисов ============

final storageServiceProvider = Provider((ref) => StorageService());
final apiClientProvider = Provider((ref) => ApiClient());

final authServiceProvider = Provider((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

final zhspkServiceProvider = Provider((ref) {
  return ZhspkService(ref.watch(apiClientProvider));
});

// ============ Провайдеры репозиториев ============

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.watch(authServiceProvider),
    ref.watch(storageServiceProvider),
    ref.watch(apiClientProvider),
  );
});

final zhspkRepositoryProvider = Provider((ref) {
  return ZhspkRepository(ref.watch(zhspkServiceProvider));
});

// ============ Login ViewModel ============

class LoginState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  LoginState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  LoginState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return LoginState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthRepository _repository;

  LoginViewModel(this._repository) : super(LoginState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuth = await _repository.checkAuth();
    if (isAuth) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> login(String login, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.login(login, password);
      if (success) {
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid credentials',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = LoginState();
  }
}

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(ref.watch(authRepositoryProvider));
});
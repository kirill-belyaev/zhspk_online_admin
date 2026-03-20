

import 'package:zhspk_online_admin/data/services/api_client.dart';
import 'package:zhspk_online_admin/data/services/auth_service.dart';
import 'package:zhspk_online_admin/data/services/storage_service.dart';

class AuthRepository {
  final AuthService _authService;
  final StorageService _storageService;
  final ApiClient _apiClient;

  AuthRepository(
      this._authService,
      this._storageService,
      this._apiClient,
      );

  Future<bool> login(String login, String password) async {
    final response = await _authService.login(login, password);

    if (response.isValid && response.token != null) {
      await _storageService.saveToken(response.token!);
      _apiClient.setToken(response.token!);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _storageService.clearToken();
    _apiClient.clearToken();
  }

  Future<bool> checkAuth() async {
    final token = await _storageService.getToken();
    if (token != null) {
      _apiClient.setToken(token);
      return true;
    }
    return false;
  }
}
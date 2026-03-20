import 'package:dio/dio.dart';
import 'package:zhspk_online_admin/data/models/auth_response.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(String login, String password) async {
    try {
      final response = await _apiClient.dio.post('/api/auth', data: {
        'login': login,
        'password': password,
      });
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }
}
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.dio.get('/user/profile');
    return response.data;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _apiClient.dio.put('/user/profile', data: data);
  }
}
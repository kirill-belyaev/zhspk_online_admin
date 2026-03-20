import 'package:dio/dio.dart';
import '../models/zhspk_response.dart';
import 'api_client.dart';

class ZhspkService {
  final ApiClient _apiClient;

  ZhspkService(this._apiClient);

  Future<List<ZhspkResponse>> getZhspkList() async {
    try {
      final response = await _apiClient.dio.get('/api/zhspk');

      // Bearer token is added automatically via ApiClient interceptor
      return (response.data as List<dynamic>)
          .map((json) => ZhspkResponse.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - token expired');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to load zhspk');
    }
  }

  // Create new ZHSPK with name only
  Future<String> createZhspk(String name) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'zhspk_name': name,
        'total_square': 0,
      });

      final response = await _apiClient.dio.post('/api/zhspk', data: formData);

      return response.data['data'].toString();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - token expired');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to create zhspk');
    }
  }

  Future<Map<String, String>> createChairperson(
    String zhspkId,
    String lastName,
    String firstName,
  ) async {
    final response = await _apiClient.dio.post(
      '/api/loading/chairperson',
      data: {
        'zhspk_id': int.parse(zhspkId),
        'last_name': lastName,
        'first_name': firstName,
      },
    );

    return {
      'login': response.data['login'],
      'password': response.data['password'],
    };
  }
}

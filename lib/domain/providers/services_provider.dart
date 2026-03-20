import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zhspk_online_admin/data/services/api_client.dart';
import 'package:zhspk_online_admin/data/services/auth_service.dart';
import 'package:zhspk_online_admin/data/services/user_service.dart';

// API клиент
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Сервисы - легко добавлять новые
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserService(apiClient);
});
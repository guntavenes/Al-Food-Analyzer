import 'package:ai_food_analyzer/core/auth/access_token_provider.dart';
import 'package:dio/dio.dart';

class AccountService {
  const AccountService(this._dio, this._accessTokenProvider);

  final Dio _dio;
  final AccessTokenProvider _accessTokenProvider;

  Future<void> deleteAccount() async {
    final token = await _accessTokenProvider.getAccessToken();
    if (token == null) throw StateError('A signed-in account is required.');
    await _dio.delete<void>(
      '/v1/account',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}

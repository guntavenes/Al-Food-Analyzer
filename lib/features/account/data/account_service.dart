import 'package:ai_food_analyzer/core/auth/access_token_provider.dart';
import 'package:dio/dio.dart';

class AccountService {
  const AccountService(this._dio, this._accessTokenProvider);

  final Dio _dio;
  final AccessTokenProvider _accessTokenProvider;

  Future<AccountDeletionResult> deleteAccount({
    String? appleProviderToken,
    String? appleProviderTokenType,
  }) async {
    final token = await _accessTokenProvider.getAccessToken();
    if (token == null) throw StateError('A signed-in account is required.');
    final response = await _dio.delete<Map<String, dynamic>>(
      '/v1/account',
      data: {
        'appleProviderToken': ?appleProviderToken,
        'appleProviderTokenType': ?appleProviderTokenType,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return AccountDeletionResult(
      appleAuthorizationRevoked:
          response.data?['appleAuthorizationRevoked'] as bool?,
    );
  }
}

class AccountDeletionResult {
  const AccountDeletionResult({this.appleAuthorizationRevoked});

  final bool? appleAuthorizationRevoked;
}

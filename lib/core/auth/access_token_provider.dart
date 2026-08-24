import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AccessTokenProvider {
  Future<String?> getAccessToken();
}

class SupabaseAccessTokenProvider implements AccessTokenProvider {
  SupabaseAccessTokenProvider(this._client);

  final SupabaseClient _client;

  @override
  Future<String?> getAccessToken() async {
    final currentSession = _client.auth.currentSession;
    if (currentSession != null && currentSession.user.isAnonymous != true) {
      return currentSession.accessToken;
    }
    throw const AuthException('A permanent user account is required.');
  }
}

class NoopAccessTokenProvider implements AccessTokenProvider {
  const NoopAccessTokenProvider();

  @override
  Future<String?> getAccessToken() async => null;
}

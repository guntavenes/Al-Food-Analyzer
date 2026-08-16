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
    if (currentSession != null) return currentSession.accessToken;
    return (await _client.auth.signInAnonymously()).session?.accessToken;
  }
}

class NoopAccessTokenProvider implements AccessTokenProvider {
  const NoopAccessTokenProvider();

  @override
  Future<String?> getAccessToken() async => null;
}

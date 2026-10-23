import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AccessTokenProvider {
  Future<String?> getAccessToken();
  String? get userId;
  bool get requiresPermanentAccount;
}

class SupabaseAccessTokenProvider implements AccessTokenProvider {
  SupabaseAccessTokenProvider(this._client);

  final SupabaseClient _client;

  @override
  String? get userId => _client.auth.currentUser?.id;

  @override
  bool get requiresPermanentAccount =>
      _client.auth.currentUser?.isAnonymous != false;

  @override
  Future<String?> getAccessToken() async {
    var currentSession = _client.auth.currentSession;
    currentSession ??= (await _client.auth.signInAnonymously()).session;
    if (currentSession == null) {
      throw const AuthException('A valid user session is required.');
    }
    return currentSession.accessToken;
  }
}

class NoopAccessTokenProvider implements AccessTokenProvider {
  const NoopAccessTokenProvider();

  @override
  Future<String?> getAccessToken() async => null;

  @override
  String? get userId => null;

  @override
  bool get requiresPermanentAccount => true;
}

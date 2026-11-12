import 'package:google_sign_in/google_sign_in.dart';

import 'api_client.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();
  static const _serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static final _google = GoogleSignIn.instance;
  static Future<void>? _initialization;

  Future<void> signIn() async {
    if (_serverClientId.isEmpty) {
      throw const ApiException('Google sign-in is not set up yet. Add the Google web client ID to the app build.');
    }

    await (_initialization ??= _google.initialize(serverClientId: _serverClientId));
    if (!_google.supportsAuthenticate()) {
      throw const ApiException('Google sign-in is not available on this device.');
    }

    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const ApiException('Google did not return a sign-in token. Check the Google app setup.');
    }

    final response = await ApiClient.instance.post(
      'auth/google/',
      body: {'id_token': idToken},
    );
    final tokens = response['tokens'];
    if (tokens is! Map<String, dynamic>) {
      throw const ApiException('The server did not return sign-in tokens.');
    }
    await ApiClient.instance.saveTokens(tokens);
  }

  Future<void> signOut() async {
    final initialization = _initialization;
    if (initialization == null) return;
    await initialization;
    await _google.signOut();
  }
}

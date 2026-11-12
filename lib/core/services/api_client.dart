import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static const _storage = FlutterSecureStorage();
  static const _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  String get baseUrl => _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final result = await request('POST', path, body: body, authenticated: authenticated);
    if (result is Map<String, dynamic>) return result;
    throw const ApiException('The server returned an unexpected response.');
  }

  Future<dynamic> get(String path, {bool authenticated = true}) =>
      request('GET', path, authenticated: authenticated);

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final result = await request('PATCH', path, body: body, authenticated: authenticated);
    if (result is Map<String, dynamic>) return result;
    throw const ApiException('The server returned an unexpected response.');
  }

  Future<dynamic> delete(String path, {bool authenticated = true}) =>
      request('DELETE', path, authenticated: authenticated);

  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final headers = await _headers(authenticated: authenticated);
    final uri = Uri.parse('$baseUrl/$path');
    final encodedBody = body == null ? null : jsonEncode(body);
    final response = await (switch (method) {
      'GET' => http.get(uri, headers: headers),
      'POST' => http.post(uri, headers: headers, body: encodedBody),
      'PATCH' => http.patch(uri, headers: headers, body: encodedBody),
      'DELETE' => http.delete(uri, headers: headers),
      _ => throw ArgumentError.value(method, 'method', 'Unsupported HTTP method'),
    }).timeout(const Duration(seconds: 25));
    return _decode(response);
  }

  Future<Map<String, String>> _headers({required bool authenticated}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (authenticated) {
      final token = await _storage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        throw const ApiException('Please sign in again.');
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException('The server returned an unreadable response (${response.statusCode}).');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(decoded, response.statusCode));
    }
    if (decoded is! Map<String, dynamic>) {
      if (decoded is List<dynamic>) return decoded;
      throw const ApiException('The server returned an unexpected response.');
    }
    final payload = decoded['data'] ?? decoded;
    return payload;
  }

  String _errorMessage(dynamic payload, int statusCode) {
    if (payload is Map<String, dynamic>) {
      final detail = payload['detail'] ?? payload['message'];
      if (detail is String && detail.isNotEmpty) return detail;
      for (final value in payload.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String && value.isNotEmpty) return value;
      }
    }
    if (statusCode == 401) return 'Email or password is incorrect.';
    return 'Request failed ($statusCode). Please try again.';
  }

  Future<void> saveTokens(Map<String, dynamic> tokens) async {
    final access = tokens['access'] as String?;
    final refresh = tokens['refresh'] as String?;
    if (access == null || refresh == null) {
      throw const ApiException('The server did not return sign-in tokens.');
    }
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<bool> restoreSession() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final response = await post('auth/token/refresh/', body: {'refresh': refresh})
          .timeout(const Duration(seconds: 5));
      final access = response['access'] as String?;
      if (access == null || access.isEmpty) return false;
      await _storage.write(key: 'access_token', value: access);
      final rotatedRefresh = response['refresh'] as String?;
      if (rotatedRefresh != null && rotatedRefresh.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: rotatedRefresh);
      }
      return true;
    } on ApiException {
      await clearTokens();
      return false;
    } catch (_) {
      // Keep the saved session if the API is temporarily unreachable.
      return true;
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> logout() async {
    final refresh = await _storage.read(key: 'refresh_token');
    try {
      await post(
        'auth/logout/',
        body: {'refresh': refresh},
        authenticated: true,
      ).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Clear local credentials even when the server is unreachable.
    } finally {
      await clearTokens();
    }
  }
}

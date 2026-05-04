import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth.dart';

class AuthService {
  final String baseUrl;
  final bool mockMode;

  /// If [mockMode] is true the service will accept a local test account
  /// (`admin@cloudops.internal` / `Password123!`) and return a fake token.
  AuthService({String? baseUrl, this.mockMode = true})
    : baseUrl = baseUrl ?? 'https://api.example.com';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<AuthToken?> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    if (mockMode) {
      // Development mock: accept a single test account
      if (email.toLowerCase() == 'admin@cloudops.internal' &&
          password == 'Password123!') {
        final token = AuthToken(
          accessToken: 'mock-access-token',
          refreshToken: 'mock-refresh',
          expiresIn: 3600,
        );
        if (remember) await _saveToken(token);
        return token;
      }
      return null;
    }

    final uri = Uri.parse('$baseUrl/api/v1/auth/login');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final token = AuthToken.fromJson(data);
      if (remember) await _saveToken(token);
      return token;
    }
    return null;
  }

  Future<bool> logout([String? accessToken]) async {
    // If running in mock mode (dev), just clear local tokens and succeed.
    if (mockMode) {
      await _clearToken();
      return true;
    }

    final token = accessToken ?? await getSavedAccessToken();
    final uri = Uri.parse('$baseUrl/api/v1/auth/logout');
    final resp = await http.post(uri, headers: _authHeaders(token ?? ''));
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      await _clearToken();
      return true;
    }
    return false;
  }

  Future<AuthToken?> refresh(String refreshToken) async {
    if (mockMode) {
      // return refreshed mock token
      final token = AuthToken(
        accessToken: 'mock-access-token-refreshed',
        refreshToken: 'mock-refresh',
        expiresIn: 3600,
      );
      await _saveToken(token);
      return token;
    }

    final uri = Uri.parse('$baseUrl/api/v1/auth/refresh');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'refresh_token': refreshToken}),
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final token = AuthToken.fromJson(data);
      await _saveToken(token);
      return token;
    }
    return null;
  }

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Simple local storage helpers using SharedPreferences
  Future<void> _saveToken(AuthToken token) async {
    await _secure.write(key: 'auth_token', value: token.accessToken);
    if (token.refreshToken != null) {
      await _secure.write(key: 'refresh_token', value: token.refreshToken);
    }
  }

  Future<void> _clearToken() async {
    await _secure.delete(key: 'auth_token');
    await _secure.delete(key: 'refresh_token');
  }

  Future<String?> getSavedAccessToken() async {
    return await _secure.read(key: 'auth_token');
  }

  Future<String?> getSavedRefreshToken() async {
    return await _secure.read(key: 'refresh_token');
  }
}

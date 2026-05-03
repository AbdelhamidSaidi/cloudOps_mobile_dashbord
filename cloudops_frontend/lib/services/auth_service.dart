import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';

class AuthService {
  final String baseUrl;

  AuthService({String? baseUrl})
    : baseUrl = baseUrl ?? 'https://api.example.com';

  Future<AuthToken?> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
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

  Future<bool> logout(String accessToken) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/logout');
    final resp = await http.post(uri, headers: _authHeaders(accessToken));
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      await _clearToken();
      return true;
    }
    return false;
  }

  Future<AuthToken?> refresh(String refreshToken) async {
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

  Future<Map<String, String>> _authHeaders(String token) async => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Simple local storage helpers using SharedPreferences
  Future<void> _saveToken(AuthToken token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token.accessToken);
    if (token.refreshToken != null) {
      await prefs.setString('refresh_token', token.refreshToken!);
    }
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }

  Future<String?> getSavedAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'auth_service.dart';

class ApiService {
  // Update this baseUrl to your backend API host.
  final String baseUrl;

  ApiService({String? baseUrl})
    : baseUrl = baseUrl ?? 'https://api.example.com';

  final AuthService _auth = AuthService();
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const _mockUserKey = 'mock_user';

  Future<User?> getProfile() async {
    // If running in mock mode, read a locally persisted mock user.
    if (_auth.mockMode) {
      final raw = await _secure.read(key: _mockUserKey);
      if (raw != null && raw.isNotEmpty) {
        try {
          final map = json.decode(raw) as Map<String, dynamic>;
          return User.fromJson(map);
        } catch (_) {}
      }
      // create a default mock user and persist it
      final mock = User(
        id: 'local-1',
        name: 'Admin User',
        email: 'admin@cloudops.internal',
        role: 'Administrator',
        location: 'Austin, United States',
        avatarUrl: null,
      );
      await _secure.write(key: _mockUserKey, value: json.encode(mock.toJson()));
      return mock;
    }
    final uri = Uri.parse('$baseUrl/api/v1/profile');
    final resp = await _getWithAuth(uri);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return User.fromJson(data['user'] ?? data);
    }
    return null;
  }

  /// Update user profile. [updates] should contain only fields to change.
  Future<User?> updateProfile(Map<String, dynamic> updates) async {
    // Mock-mode: persist updates locally and return merged User
    if (_auth.mockMode) {
      try {
        final raw = await _secure.read(key: _mockUserKey);
        Map<String, dynamic> base = {};
        if (raw != null && raw.isNotEmpty) {
          base = json.decode(raw) as Map<String, dynamic>;
        }
        // merge
        updates.forEach((k, v) => base[k] = v);
        await _secure.write(key: _mockUserKey, value: json.encode(base));
        return User.fromJson(base);
      } catch (e) {
        return null;
      }
    }

    final uri = Uri.parse('$baseUrl/api/v1/profile');
    try {
      var headers = await _defaultHeaders();
      var resp = await http.patch(
        uri,
        headers: headers,
        body: json.encode(updates),
      );
      if (resp.statusCode == 401) {
        final refresh = await _auth.getSavedRefreshToken();
        if (refresh != null && refresh.isNotEmpty) {
          final newToken = await _auth.refresh(refresh);
          if (newToken != null) {
            headers = await _defaultHeaders();
            resp = await http.patch(
              uri,
              headers: headers,
              body: json.encode(updates),
            );
          }
        }
      }
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        return User.fromJson(data['user'] ?? data);
      }
    } catch (e) {
      // ignore and return null
    }
    return null;
  }

  /// Upload avatar image bytes. Returns updated `User` on success.
  Future<User?> uploadAvatarFromBytes(
    String filename,
    List<int> bytes, {
    String? mimeType,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/profile/avatar');
    final token = await _auth.getSavedAccessToken();
    final req = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    // If mimeType isn't provided, MultipartFile will omit Content-Type
    req.files.add(
      http.MultipartFile.fromBytes('avatar', bytes, filename: filename),
    );
    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return User.fromJson(data['user'] ?? data);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final uri = Uri.parse('$baseUrl/api/v1/settings');
    final resp = await _getWithAuth(uri);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getNotifications() async {
    final uri = Uri.parse('$baseUrl/api/v1/notifications');
    final resp = await _getWithAuth(uri);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(
          data.map((e) => e as Map<String, dynamic>),
        );
      }
    }
    return null;
  }

  // Send GET with Authorization header and retry once after refresh on 401
  Future<http.Response> _getWithAuth(Uri uri) async {
    var headers = await _defaultHeaders();
    var resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 401) {
      // try to refresh
      final refresh = await _auth.getSavedRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
        final newToken = await _auth.refresh(refresh);
        if (newToken != null) {
          headers = await _defaultHeaders();
          resp = await http.get(uri, headers: headers);
        }
      }
    }
    return resp;
  }

  Future<Map<String, String>> _defaultHeaders() async {
    final token = await _auth.getSavedAccessToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}

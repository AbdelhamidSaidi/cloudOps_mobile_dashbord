import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  // Update this baseUrl to your backend API host.
  final String baseUrl;

  ApiService({String? baseUrl})
    : baseUrl = baseUrl ?? 'https://api.example.com';

  Future<User?> getProfile() async {
    final uri = Uri.parse(
      '\$baseUrl/api/v1/profile'.replaceFirst(r'\$baseUrl', baseUrl),
    );
    final resp = await http.get(uri, headers: _defaultHeaders());
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return User.fromJson(data['user'] ?? data);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final uri = Uri.parse(
      '\$baseUrl/api/v1/settings'.replaceFirst(r'\$baseUrl', baseUrl),
    );
    final resp = await http.get(uri, headers: _defaultHeaders());
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getNotifications() async {
    final uri = Uri.parse(
      '\$baseUrl/api/v1/notifications'.replaceFirst(r'\$baseUrl', baseUrl),
    );
    final resp = await http.get(uri, headers: _defaultHeaders());
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

  Map<String, String> _defaultHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // Add Authorization header here if needed
    };
  }
}

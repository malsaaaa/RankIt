import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthApiService {
  final String _baseUrl = ApiService.baseUrl;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Failed to register (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred during registration: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Failed to login (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred during login: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Failed to fetch user (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred while fetching user: $e');
    }
  }

  Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return;
      } else {
        String errorMessage = 'Failed to logout (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred during logout: $e');
    }
  }
}

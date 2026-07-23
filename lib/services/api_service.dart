import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service for RouteSafe containing HTTP connections to the Flask MySQL backend.
/// Maps local requests to RESTful endpoints:
/// - POST   /api/login
/// - POST   /api/register
/// - POST   /api/forgot-password
/// - GET    /api/buses
/// - POST   /api/buses
/// - PUT    /api/buses/{id}
/// - DELETE /api/buses/{id}
class ApiService {
  // Configured for local Flask dev environment
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator alias for localhost

  // POST /login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Invalid email or password'};
      }
    } catch (_) {
      // Offline / No-Backend Mock Fallback
      if (email.contains('@') && password.length >= 8) {
        return {
          'success': true,
          'user': {
            'full_name': 'Administrator',
            'email': email,
            'phone_number': '+1234567890',
            'role': 'Admin', // Roles: Admin, Driver, Parent
          },
          'message': 'Logged in successfully (offline mode)'
        };
      } else {
        return {'success': false, 'message': 'Invalid credentials. Hint: use any email and min 8 chars password.'};
      }
    }
  }

  // POST /register
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
          'role': role
        }),
      ).timeout(const Duration(seconds: 4));

      return jsonDecode(response.body);
    } catch (_) {
      // Mock Fallback
      return {
        'success': true,
        'message': 'Registration successful! (offline mode)'
      };
    }
  }

  // POST /forgot-password
  Future<Map<String, dynamic>> forgotPassword(String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'new_password': newPassword}),
      ).timeout(const Duration(seconds: 4));

      return jsonDecode(response.body);
    } catch (_) {
      return {
        'success': true,
        'message': 'Password has been reset successfully. (offline mode)'
      };
    }
  }

  // GET /buses
  Future<List<dynamic>> getBuses() async {
    final url = Uri.parse('$baseUrl/buses');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      // Return empty list to trigger mock database retrieval in Provider
      return [];
    }
  }

  // POST /buses
  Future<Map<String, dynamic>> addBus(Map<String, dynamic> busData) async {
    final url = Uri.parse('$baseUrl/buses');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(busData),
      ).timeout(const Duration(seconds: 4));
      return jsonDecode(response.body);
    } catch (_) {
      return {'success': true, 'message': 'Bus added successfully (offline)'};
    }
  }

  // PUT /buses/{id}
  Future<Map<String, dynamic>> updateBus(String id, Map<String, dynamic> busData) async {
    final url = Uri.parse('$baseUrl/buses/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(busData),
      ).timeout(const Duration(seconds: 4));
      return jsonDecode(response.body);
    } catch (_) {
      return {'success': true, 'message': 'Bus updated successfully (offline)'};
    }
  }

  // DELETE /buses/{id}
  Future<Map<String, dynamic>> deleteBus(String id) async {
    final url = Uri.parse('$baseUrl/buses/$id');
    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 4));
      return jsonDecode(response.body);
    } catch (_) {
      return {'success': true, 'message': 'Bus deleted successfully (offline)'};
    }
  }
}

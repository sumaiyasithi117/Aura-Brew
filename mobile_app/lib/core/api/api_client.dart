import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// Centralized HTTP client that handles auth token injection and error handling.
class ApiClient {
  static const String _tokenKey = 'auth_token';

  // ── Token Management ──
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Headers ──
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Token $token';
      }
    }
    return headers;
  }

  // ── GET ──
  static Future<dynamic> get(String endpoint, {bool auth = true}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.get(url, headers: await _headers(auth: auth));
    return _handleResponse(response);
  }

  // ── POST ──
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.post(
      url,
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  // ── PATCH ──
  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.patch(
      url,
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patchMultipart(
    String endpoint, {
    Map<String, String>? fields,
    http.MultipartFile? file,
    bool auth = true,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest('PATCH', url);
    
    if (auth) {
      final token = await getToken();
      if (token != null) request.headers['Authorization'] = 'Token $token';
    }

    if (fields != null) request.fields.addAll(fields);
    if (file != null) request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // ── PUT ──
  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.put(
      url,
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  // ── DELETE ──
  static Future<dynamic> delete(String endpoint, {bool auth = true}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.delete(
      url,
      headers: await _headers(auth: auth),
    );
    return _handleResponse(response);
  }

  // ── Response Handler ──
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      String message = 'Request failed';
      if (body is Map) {
        if (body.containsKey('detail')) {
          message = body['detail'];
        } else if (body.containsKey('non_field_errors')) {
          message = (body['non_field_errors'] as List).join(', ');
        } else {
          // Collect all field errors
          final errors = <String>[];
          body.forEach((key, value) {
            if (value is List) {
              errors.add('$key: ${value.join(', ')}');
            }
          });
          if (errors.isNotEmpty) message = errors.join('\n');
        }
      }
      throw ApiException(message, response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

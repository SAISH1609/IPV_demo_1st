import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/attendance.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );
  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<User> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access_token']);
      return {
        'user': User.fromJson(data['user']),
        'token': data['access_token'],
      };
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> checkIn(List<int> imageBytes) async {
    final headers = await _getHeaders();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/attendance/check-in'),
    );

    request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'check_in.jpg',
      ),
    );

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to check in: ${await response.stream.bytesToString()}',
      );
    }
  }

  Future<void> checkOut() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/attendance/check-out'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to check out: ${response.body}');
    }
  }

  Future<List<Attendance>> getReports({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final headers = await _getHeaders();
    final queryParams = {
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    final response = await http.get(
      Uri.parse(
        '$baseUrl/attendance/reports',
      ).replace(queryParameters: queryParams),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['attendances'] as List)
          .map((json) => Attendance.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to get reports: ${response.body}');
    }
  }
}

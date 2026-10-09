import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'device_id.dart';

const String apiBaseUrl = 'https://coaching-beta-seven.vercel.app/api';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  final _storage = const FlutterSecureStorage();

  Future<String?> get _token => _storage.read(key: 'token');

  Future<void> login(String email, String password) async {
    final deviceId = await getDeviceId();
    final res = await http.post(
      Uri.parse('$apiBaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'deviceId': deviceId}),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw ApiException(body['error'] ?? 'Login failed');
    }

    await _storage.write(key: 'token', value: body['token']);
  }

  Future<void> logout() => _storage.delete(key: 'token');

  Future<List<dynamic>> fetchCourses() async {
    final token = await _token;
    final res = await http.get(
      Uri.parse('$apiBaseUrl/courses'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw ApiException(body['error'] ?? 'Could not load courses');
    }
    return body['courses'];
  }

  /// Starts a purchase: asks the backend for a Razorpay order for this course.
  /// Returns the raw fields the Razorpay checkout SDK needs.
  Future<Map<String, dynamic>> createOrder(String courseId) async {
    final token = await _token;
    final res = await http.post(
      Uri.parse('$apiBaseUrl/payments/create-order'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'courseId': courseId}),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw ApiException(body['error'] ?? 'Could not start payment');
    }
    return body;
  }

  /// Called after the Razorpay checkout UI reports success — the backend verifies
  /// the signature server-side and only then enrolls the student. Never trust the
  /// checkout success callback alone; the app can be tampered with.
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final token = await _token;
    final res = await http.post(
      Uri.parse('$apiBaseUrl/payments/verify'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw ApiException(body['error'] ?? 'Payment verification failed');
    }
  }

  Future<List<dynamic>> fetchLessons(String courseId) async {
    final token = await _token;
    final res = await http.get(
      Uri.parse('$apiBaseUrl/courses/$courseId/lessons'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw ApiException(body['error'] ?? 'Could not load lessons');
    }
    return body['lessons'];
  }

  /// A fresh signed URL, valid for about an hour — fetch right before playing,
  /// don't cache it across app sessions.
  Future<String> fetchVideoUrl(String lessonId) async {
    final token = await _token;
    final res = await http.get(
      Uri.parse('$apiBaseUrl/lessons/$lessonId/video-url'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw ApiException(body['error'] ?? 'Could not load video');
    }
    return body['url'];
  }
}

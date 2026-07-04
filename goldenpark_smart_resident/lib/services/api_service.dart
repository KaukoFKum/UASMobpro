import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/resident_model.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const bool sendAuthToken = bool.fromEnvironment(
    'API_SEND_AUTH',
    defaultValue: false,
  );

  static const Duration _timeout = Duration(seconds: 15);

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    return kIsWeb
        ? 'http://127.0.0.1:8000/api'
        : 'http://192.168.100.73:8000/api';
  }

  static Future<Map<String, String>> _headers({
    bool includeJsonContentType = false,
  }) async {
    final token = sendAuthToken
        ? await FirebaseAuth.instance.currentUser?.getIdToken()
        : null;

    return {
      'Accept': 'application/json',
      if (includeJsonContentType) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Resident>> getResidents() async {
    final uri = Uri.parse('$baseUrl/residents');

    try {
      final response = await http
          .get(
            uri,
            headers: await _headers(),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData['data'];

        if (data is! List) {
          throw const ApiException('Format data resident tidak valid');
        }

        return data.map((e) => Resident.fromJson(e)).toList();
      }

      throw ApiException(
        'Gagal memuat resident (${response.statusCode}) dari $uri',
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Timeout menghubungi server resident: $uri');
    } on FormatException {
      throw ApiException('Response server bukan JSON valid: $uri');
    } on http.ClientException catch (e) {
      throw ApiException(
        'Gagal menghubungi $uri. Detail: ${e.message}. '
        'Jika ini di Chrome, cek CORS Laravel.',
      );
    } catch (_) {
      throw ApiException('Gagal terhubung ke server resident: $uri');
    }
  }

  static Future<bool> addResident(Resident resident) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/residents'),
            headers: await _headers(includeJsonContentType: true),
            body: jsonEncode(resident.toJson()),
          )
          .timeout(_timeout);

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateResident(int id, Resident resident) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/residents/$id'),
            headers: await _headers(includeJsonContentType: true),
            body: jsonEncode(resident.toJson()),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteResident(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/residents/$id'),
            headers: await _headers(),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

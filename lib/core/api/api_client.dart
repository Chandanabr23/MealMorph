import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => 'ApiException($status): $message';
}

/// Thin wrapper around the MealMorph backend.
class ApiClient {
  ApiClient({http.Client? inner, String? baseUrl})
    : _inner = inner ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _inner;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await _inner.get(_uri(path));
    return _decode(res);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await _inner.post(
      _uri(path),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> postImage(
    String path, {
    required String field,
    required File file,
  }) async {
    final req = http.MultipartRequest('POST', _uri(path));
    req.files.add(await http.MultipartFile.fromPath(field, file.path));
    final streamed = await _inner.send(req);
    final res = await http.Response.fromStream(streamed);
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300 && body != null) {
      return body;
    }
    final msg = body?['message'] as String? ?? 'Request failed (${res.statusCode}).';
    throw ApiException(msg, status: res.statusCode);
  }

  void close() => _inner.close();
}

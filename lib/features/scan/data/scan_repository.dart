import 'dart:io';

import '../../../core/api/api_client.dart';
import '../domain/scan_result.dart';

enum ScanMode { fridge, receipt }

class ScanRepository {
  ScanRepository({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<ScanResponse> analyse({required File image, required ScanMode mode}) async {
    final path = mode == ScanMode.receipt ? '/api/scan/receipt' : '/api/scan/fridge';
    final body = await _api.postImage(path, field: 'image', file: image);
    final raw = (body['items'] as List?) ?? const [];
    return ScanResponse(
      mode: (body['mode'] as String?) ?? 'unknown',
      items: raw
          .whereType<Map<String, dynamic>>()
          .map(DetectedIngredient.fromJson)
          .toList(),
    );
  }
}

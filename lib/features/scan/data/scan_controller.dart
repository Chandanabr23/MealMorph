import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../fridge/data/fridge_repository.dart';
import '../../fridge/domain/fridge_item.dart';
import 'scan_repository.dart';

enum ScanStatus { idle, analyzing, success, failure }

class ScanState {
  const ScanState({
    this.status = ScanStatus.idle,
    this.error,
    this.lastItemCount = 0,
    this.lastMode = 'unknown',
  });

  final ScanStatus status;
  final Object? error;
  final int lastItemCount;
  final String lastMode;

  bool get isBusy => status == ScanStatus.analyzing;
}

/// Owns the scan analysis lifecycle so the request keeps running even if the
/// user navigates away from [ScanScreen]. Pushes detected ingredients straight
/// into [FridgeRepository] and exposes progress via [state].
class ScanController {
  ScanController._({ScanRepository? repository, FridgeRepository? fridge})
    : _repo = repository ?? ScanRepository(),
      _fridge = fridge ?? FridgeRepository.instance;

  static final ScanController instance = ScanController._();

  final ScanRepository _repo;
  final FridgeRepository _fridge;

  final ValueNotifier<ScanState> state = ValueNotifier<ScanState>(
    const ScanState(),
  );

  Future<void> analyze({required File image, required ScanMode mode}) async {
    state.value = const ScanState(status: ScanStatus.analyzing);
    try {
      final res = await _repo.analyse(image: image, mode: mode);
      final items = res.items;
      if (items.isNotEmpty) {
        final now = DateTime.now().microsecondsSinceEpoch;
        _fridge.addAll(
          items.asMap().entries.map((e) {
            final d = e.value;
            return FridgeItem(
              id: 'scan-$now-${e.key}',
              name: d.name,
              detail: d.quantity,
              category: d.category,
              imagePath: image.path,
            );
          }),
        );
      }
      state.value = ScanState(
        status: ScanStatus.success,
        lastItemCount: items.length,
        lastMode: res.mode,
      );
    } catch (e) {
      state.value = ScanState(status: ScanStatus.failure, error: e);
    }
  }

  void reset() {
    state.value = const ScanState();
  }
}

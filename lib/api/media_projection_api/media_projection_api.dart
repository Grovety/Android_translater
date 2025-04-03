import 'dart:developer';

import 'package:flutter/services.dart';

import 'captured_image.dart';

class MediaProjectionApi {
  static bool _isGranted = false;

  static bool get isGranted => _isGranted;

  final _captureStream =
      const EventChannel('media_projection_api/event').receiveBroadcastStream();

  final _methodChannel = const MethodChannel('media_projection_api');

  Future<bool> checkPermissions() async {
    if (!isGranted) {
      final result = await _methodChannel.invokeMethod<bool>('checkPermission');
      log('checkPermissions result: $result');
      if (result ?? true) {
        _isGranted = true;
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  /// Check if MediaProjection permission is granted
  Future<bool> isPermissionGranted() async {
    try {
      log('isPermissionGranted starts');
      return await _methodChannel.invokeMethod<bool>('checkPermission') ??
          false;
    } on PlatformException catch (error) {
      log("MediaProjectionApi error: $error");
      return Future.value(false);
    }
  }

  /// take capture
  /// return captured image [CapturedImage]
  /// x: capture from [int] x
  /// y: capture to [int] y
  /// width: capture width pixels [int]
  /// height: capture size height pixels [int]
  /// if x, y, width, height are booth null, capture full screen
  /// if x, y, width, height are booth not null, capture specified area
  Future<CapturedImage?> takeCapture({
    int? x,
    int? y,
    int? width,
    int? height,
  }) async {
    Map<String, dynamic>? data;
    if (x != null && y != null && width != null && height != null) {
      data = {'x': x, 'y': y, 'width': width, 'height': height};
    }
    final result = await _methodChannel.invokeMethod('takeCapture', data);
    if (result == null) {
      return null;
    }
    final imageData = CapturedImage.fromMap(Map<String, dynamic>.from(result));
    log('Taking Image result $imageData');
    return imageData;
  }

  Future<bool> startCapture({
    int? x,
    int? y,
    int? width,
    int? height,
    int fps = 15,
  }) async {
    Map<String, dynamic>? data;
    if (x != null && y != null && width != null && height != null) {
      data = {'x': x, 'y': y, 'width': width, 'height': height};
    }
    final result = await _methodChannel.invokeMethod('startCapture', data);
    log('Image result $result');
    return result;
  }

  Future<Stream<dynamic>?> startCaptureStream({
    int? x,
    int? y,
    int? width,
    int? height,
    int fps = 15,
  }) async {
    try {
      Map<String, dynamic>? data;
      if (x != null && y != null && width != null && height != null) {
        data = {'x': x, 'y': y, 'width': width, 'height': height};
      }
      if (data != null) {
        final result = await _methodChannel.invokeMethod(
          'startCaptureStream',
          data,
        );
        if (result) return _captureStream;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> stopCapture() async {
    return await _methodChannel.invokeMethod('stopCapture');
  }
}

import 'dart:async';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  // int _topSize = 0;
  // int _bottomSize = 0;
  // int _widthSize = 0;
  // int _heightSize = 0;
  static const int startHeight = 100;

  static bool isShowing = false;

  Future<void> showOverlay({int height = startHeight, int position = 0}) async {
    if (position != 0) {
      height = WindowSize.matchParent;
    }
    isShowing = true;
    return await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: height,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.bottomCenter,
      startPosition: OverlayPosition(0, 0),
    );
  }

  Future<void> closeOverlay() async {
    FlutterOverlayWindow.disposeOverlayListener();
    isShowing = false;
    await FlutterOverlayWindow.closeOverlay();
  }

  Future<bool> checkPermissions() async {
    final bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) {
      final bool? status = await FlutterOverlayWindow.requestPermission();
      return status ?? false;
    }
    return isGranted;
  }

  Future<void> resizeOverlay(bool flag) async {
    int position = 0;
    if (flag) {
      position = -startHeight;
    }
    await closeOverlay();
    await showOverlay(position: position);
  }

  Future<bool> checkActiveOverlay() async =>
      await FlutterOverlayWindow.isActive();

  // void updateOverlaySize(int width, int height, int top, int bottom) {
  //   _widthSize = width;
  //   _heightSize = height;
  //   _topSize = top;
  //   _bottomSize = bottom;
  //   // log(
  //   //   'Overlay Size updated:  width: $_widthSize, height: $_heightSize, top: $top, bottom, $bottom',
  //   // );
  // }
}

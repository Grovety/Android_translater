import 'dart:isolate';
import 'dart:ui';

import 'package:multilingual_app/helper.dart';

class AppPorts {
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameApp = 'APP';

  final _overlayReceivePort = ReceivePort();
  SendPort? _overlaySendPort;

  final _appReceivePort = ReceivePort();
  SendPort? _appSendPort;

  void initOverlayPorts(Function messageProcessing) {
    if (_overlaySendPort != null) return;
    _overlaySendPort ??= IsolateNameServer.lookupPortByName(_kPortNameApp);
    final res = IsolateNameServer.registerPortWithName(
      _overlayReceivePort.sendPort,
      _kPortNameOverlay,
    );
    log("Overlay ports init: $res");

    _overlayReceivePort.listen((message) => messageProcessing(message));
  }

  void initAppPorts(Function messageProcessing) {
    if (_appSendPort != null) return;
    _appSendPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
    final res = IsolateNameServer.registerPortWithName(
      _appReceivePort.sendPort,
      _kPortNameApp,
    );
    log("App port init: $res");
    _appReceivePort.listen((message) => messageProcessing(message));
  }

  void closeOverlayPorts() {
    _overlayReceivePort.close();
  }

  void closeAppPorts() {
    _appReceivePort.close();
  }

  void sendMessage(MessageSource source, String message) {
    String sendPortName = '';
    String acceptPortName = '';
    SendPort? sendPort;
    if (source == MessageSource.app) {
      sendPortName = _kPortNameApp;
      acceptPortName = _kPortNameOverlay;
      sendPort = _appSendPort;
    } else {
      sendPortName = _kPortNameOverlay;
      acceptPortName = _kPortNameApp;
      sendPort = _overlaySendPort;
    }

    log(
      'Send port: $sendPortName, accept port: $acceptPortName, message: $message',
    );
    if (sendPort == null) {
      log('$sendPortName is null');
      sendPort ??= IsolateNameServer.lookupPortByName(acceptPortName);
    }
    sendPort?.send(message);
  }
}

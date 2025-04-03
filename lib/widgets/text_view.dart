import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multilingual_app/widgets/settings.dart';
import 'package:multilingual_app/helper.dart';

class TextView extends StatefulWidget {
  const TextView({super.key});

  @override
  State<TextView> createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  bool _isShownOverlay = false;

  late TranslateScreenText _translateScreen;
  late Widget languageWidget;

  @override
  void initState() {
    super.initState();
    _translateScreen = TranslateScreenText();
    final isGranted = mediaProjectionApi.checkPermissions();
    log('Media Projection isGranted $isGranted');

    _initPorts();
  }

  @override
  void dispose() {
    _translateScreen.closeServices();
    overlayService.closeOverlay();
    appPorts.closeAppPorts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => _showOverlay(),
              child: Text(
                _isShownOverlay ? 'stop_button'.tr() : 'start_button'.tr(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => _showSettings(),
              child: Text('settings_button'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettings() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Settings();
      },
    );
  }

  void _initPorts() => appPorts.initAppPorts(_messageProcessing);

  void _messageProcessing(String message) {
    log('App _messageProcessing accepted $message');
    if (message == Messages.translate.name) {
      _getTextFromScreen().then(
        (message) => _sendToOverlay(message, isJson: true),
      );
    } else if (message == Messages.close.name) {
      setState(() {
        overlayService.closeOverlay();
        _isShownOverlay = false;
        _translateScreen.closeServices();
      });
    } else if (message == Messages.maximize.name) {
      overlayService.resizeOverlay(true);
    } else if (message == Messages.minimize.name) {
      overlayService.resizeOverlay(false);
    }
  }

  void _sendToOverlay(String message, {bool isJson = false}) {
    final data = isJson ? '{"data": $message}' : '{"data": "$message"}';
    appPorts.sendMessage(MessageSource.app, data);
  }

  Future<String> _getTextFromScreen() async {
    try {
      final textData = await _translateScreen.translateScreenText();
      if (textData != null) return convertTextToJson(textData);

      setState(() {});
    } catch (error) {
      log('_getTextFromScreen error: $error');
    }
    return Messages.error.name;
  }

  Future<void> _showOverlay() async {
    _isShownOverlay = !_isShownOverlay;
    _sendToOverlay(Messages.baseState.name);
    if (_isShownOverlay) {
      final isGranted = await overlayService.checkPermissions();
      if (isGranted) {
        await overlayService.showOverlay();
      } else {
        _isShownOverlay = false;
        log('No permissions for overlay showing');
      }
    } else {
      log('Close overlay');
      await overlayService.closeOverlay();
    }
    setState(() {});
  }
}

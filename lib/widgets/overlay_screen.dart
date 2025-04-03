import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:multilingual_app/widgets/translated_text_painter.dart';
import 'package:multilingual_app/helper.dart';

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({super.key});

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  bool _translating = false;
  bool _isShowingContent = false;

  Widget _widget = Container();
  Widget _startButton = Container();

  @override
  void initState() {
    super.initState();

    _updateStartButton();
    appPorts.initOverlayPorts(_messageProcessing);
  }

  @override
  void dispose() {
    sendToHome(Messages.close.name);
    appPorts.closeOverlayPorts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            _widget,
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Spacer(),
                    _startButton,
                    SizedBox(width: 5),
                    IconButton(
                      onPressed: () => _resizeOverlay(),
                      icon:
                          _isShowingContent
                              ? const Icon(
                                Icons.minimize,
                                color: Colors.black,
                                size: 15,
                              )
                              : const Icon(
                                Icons.maximize,
                                color: Colors.black,
                                size: 15,
                              ),
                    ),
                    SizedBox(width: 5),
                    IconButton(
                      onPressed: () async => _closeOverlay(),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _closeOverlay() {
    _translating = false;
    _updateContent(_createContent(Messages.baseState.name));
    sendToHome(Messages.close.name);
  }

  void _resizeOverlay() {
    _isShowingContent = !_isShowingContent;
    final message =
        _isShowingContent ? Messages.maximize.name : Messages.minimize.name;
    sendToHome(message);
    setState(() {});
  }

  void _messageProcessing(String message) {
    _translating = false;
    _updateContent(message);
  }

  void _updateContent(String message) => setState(() {
    _updateStartButton();
    final translatedScreen = _createWidget(message);
    _widget = translatedScreen;
  });

  void _updateStartButton() =>
      _startButton =
          _translating
              ? SizedBox(
                height: 35,
                width: 35,
                child: CircularProgressIndicator(padding: EdgeInsets.all(8.0)),
              )
              : IconButton(
                onPressed: () => _getTextFromScreen(),
                icon: Image.asset('assets/translate.png', width: 30),
              );

  void _getTextFromScreen() {
    try {
      _translating = true;
      _updateContent(_createContent(Messages.translate.name));
      setState(() {});
      sendToHome(Messages.translate.name);
    } catch (error) {
      log('Isolate message sending error: $error');
    }
  }

  Widget _createWidget(String message) {
    try {
      log("Create widget accepted message: $message");
      _isShowingContent = false;
      final jsonMap = jsonDecode(message) as Map<String, dynamic>;
      final data = jsonMap['data'];
      if (data is Map<String, dynamic>) {
        final overlayData = recognizedTextFromJson(data);
        final pixelRatio = MediaQuery.of(context).devicePixelRatio;
        final painter = TranslatedTextPainter(overlayData, pixelRatio);
        _resizeOverlay();
        return CustomPaint(painter: painter);
      }
      if (data == Messages.error.name) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(message),
        );
      } else if (data == Messages.baseState.name ||
          data == Messages.translate.name) {
        return Container();
      }
    } catch (error) {
      log('_createWidget error: $error');
    }
    return Container();
  }

  void sendToHome(String message) =>
      appPorts.sendMessage(MessageSource.overlay, message);

  String _createContent(String message) => '{"data": "$message"}';
}

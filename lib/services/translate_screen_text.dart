import 'dart:typed_data';

import 'package:multilingual_app/helper.dart';
import 'package:multilingual_app/models/recognized_text_model.dart';

class TranslateScreenText {
  OnDeviceTranslator? _translator;

  String _bcpTargetLanguage = L10n.curTargetLanguage;
  String _bcpSourceLanguage = L10n.curSourceLanguage;

  List<String> translatedTextList = [];

  /// main function. It captures the screen, recognizes and translates text
  Future<RecognizedText?> translateScreenText() async {
    final imageData = await _takeCaptureData();
    if (imageData == null) return null;

    final recognizedTextList = await recognitionApi.recognizeText(imageData);
    _deleteTmpData();
    if (recognizedTextList.isEmpty) return null;

    final result = await _textTranslate(recognizedTextList);
    final blocks = GoogleTextRecognitionApi.recognizedBlocks;

    final len =
        blocks.length < translatedTextList.length
            ? blocks.length
            : translatedTextList.length;

    List<TextBlock> translatedBlocs = List.generate(len, (index) {
      return TextBlock(
        text: translatedTextList[index],
        lines: blocks[index].lines,
        boundingBox: blocks[index].boundingBox,
        recognizedLanguages: blocks[index].recognizedLanguages,
        cornerPoints: blocks[index].cornerPoints,
      );
    });

    RecognizedText translatedText = RecognizedText(
      text: result,
      blocks: translatedBlocs,
    );
    return translatedText;
  }

  Future<String> _textTranslate(List<RecognizedTextModel> textList) async {
    _checkLanguageModel(textList.first.language);
    await _checkLanguages();

    String resultText = '';
    log('_bcpTargetLanguage: $_bcpTargetLanguage\n');
    translatedTextList.clear();
    try {
      for (final textPart in textList) {
        if (_bcpSourceLanguage != 'fr' || _translator == null) {
          await _translator?.close();

          _translator = translationApi.createTranslator(
            _bcpSourceLanguage,
            _bcpTargetLanguage,
          );
          log('_bcpSourceLanguage: $_bcpSourceLanguage\n');
        }
        if (_translator == null) {
          return textPart.text;
        }

        final result =
            _translator == null
                ? textPart.text
                : await translationApi.translate(textPart.text, _translator!);

        resultText += '$result\n';
        translatedTextList.add(result);
      }

      return resultText;
    } catch (error) {
      return List.generate(
        textList.length,
        (index) => textList[index].text,
      ).join('\n');
    }
  }

  void _deleteTmpData() => recognitionApi.deleteTmpFile();

  Future<bool> _checkMediaProjectionPermissions() async {
    bool isGranted = MediaProjectionApi.isGranted;
    if (!isGranted) {
      isGranted = await mediaProjectionApi.checkPermissions();
    }
    log('Media projection permissions: $isGranted');
    return isGranted;
  }

  Future<Uint8List?> _takeCaptureData() async {
    try {
      final isGranted = await _checkMediaProjectionPermissions();
      if (isGranted) {
        await overlayService.closeOverlay();

        final imageData = await mediaProjectionApi.takeCapture();

        overlayService.showOverlay();
        return imageData?.bytes;
      }
    } catch (error) {
      log('_takeCapture error: $error');
    }
    return null;
  }

  Future<void> _checkLanguageModel(String language) async {
    if (language == 'und') {
      final result = await translationApi.checkModel(_bcpSourceLanguage);
      log("Language model $_bcpSourceLanguage downloaded $result");
    }
  }

  Future<void> _checkLanguages() async {
    final currentLocaleLanguage = L10n.curTargetLanguage;
    _bcpSourceLanguage = L10n.curSourceLanguage;
    if (_bcpTargetLanguage != currentLocaleLanguage) {
      _bcpTargetLanguage = currentLocaleLanguage;
      await _translator?.close();
      _translator = null;
    }
  }

  Future<void> closeServices() async {
    await recognitionApi.closeRecognizer();
    if (_translator != null) {
      await translationApi.closeTranslator(_translator!);
    }
  }
}

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:multilingual_app/models/recognized_text_model.dart';

class GoogleTextRecognitionApi {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final String _filePath;
  List<RecognizedTextModel> _recognizedTextList = [];
  static List<TextBlock> recognizedBlocks = [];

  GoogleTextRecognitionApi() : _filePath = _getTmpFilePath();

  static String _getTmpFilePath() {
    final directory = Directory.systemTemp;
    return '${directory.path}/temp_image.png';
  }

  Future<List<RecognizedTextModel>> recognizeText(Uint8List bytes) async {
    await _getImage(bytes);
    return _recognizedTextList;
  }

  Future<void> deleteTmpFile() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        await file.delete();
        log('Tmp file image is deleted: $_filePath');
      } else {
        log('Tmp file do not exist: $_filePath');
      }
    } catch (e) {
      log('Tmp file delete error: $e');
    }
  }

  Future<void> _getImage(Uint8List bytes) async {
    // Save Uint8List as file
    final imageFile = File(_filePath);
    await imageFile.writeAsBytes(bytes);
    await _processFile(imageFile);
  }

  Future<void> _processFile(File file) async {
    final inputImage = InputImage.fromFile(file);
    await _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );
      recognizedBlocks = recognizedText.blocks;
      _recognizedTextList = List<RecognizedTextModel>.generate(
        recognizedBlocks.length,
        (int index) => recognizedBlocks[index].blockConvert(),
      );
    } catch (error) {
      log('_processImage error: $error');
      recognizedBlocks.clear();
      _recognizedTextList.clear();
    }
  }

  Future<void> closeRecognizer() async {
    await _textRecognizer.close();
  }
}

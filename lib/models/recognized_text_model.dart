import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecognizedTextModel {
  String text;
  String language;

  RecognizedTextModel({required this.text, required this.language});

  @override
  String toString() {
    return 'language: $language\n$text';
  }
}

extension BlockToRecognizedTextModel on TextBlock {
  RecognizedTextModel blockConvert() {
    // log('RecognizedTextModel languages: $recognizedLanguages');
    return RecognizedTextModel(text: text, language: recognizedLanguages.first);
  }
}

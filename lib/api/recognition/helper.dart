import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Map<String, dynamic> recognizedTextToJson(RecognizedText recognizedText) {
  return {
    'text': recognizedText.text,
    'blocks':
        recognizedText.blocks.map((block) => _textBlockToJson(block)).toList(),
  };
}

Map<String, dynamic> _textBlockToJson(TextBlock block) {
  return {
    'text': block.text,
    'boundingBox': _rectToJson(block.boundingBox),
    'cornerPoints': block.cornerPoints.map(_pointToJson).toList(),
    'recognizedLanguages': block.recognizedLanguages,
    'lines': block.lines.map(_textLineToJson).toList(),
  };
}

Map<String, dynamic> _textLineToJson(TextLine line) {
  return {
    'text': line.text,
    'boundingBox': _rectToJson(line.boundingBox),
    'cornerPoints': line.cornerPoints.map(_pointToJson).toList(),
    'recognizedLanguages': line.recognizedLanguages,
    'elements': line.elements.map(_textElementToJson).toList(),
  };
}

Map<String, dynamic> _textElementToJson(TextElement element) {
  return {
    'text': element.text,
    'boundingBox': _rectToJson(element.boundingBox),
    'cornerPoints': element.cornerPoints.map(_pointToJson).toList(),
  };
}

Map<String, dynamic> _rectToJson(Rect rect) {
  return {
    'left': rect.left,
    'top': rect.top,
    'right': rect.right,
    'bottom': rect.bottom,
  };
}

Map<String, dynamic> _pointToJson(Point<int> point) {
  return {'x': point.x, 'y': point.y};
}

String convertTextToJson(RecognizedText recognizedText) {
  final jsonMap = recognizedTextToJson(recognizedText);
  developer.log('Translated data: ${jsonEncode(jsonMap)}');
  return jsonEncode(jsonMap);
}

RecognizedText recognizedTextFromJson(Map<String, dynamic> json) {
  return RecognizedText(
    text: json['text'] ?? '',
    blocks:
        (json['blocks'] as List<dynamic>?)
            ?.map((block) => _textBlockFromJson(block))
            .toList() ??
        [],
  );
}

TextBlock _textBlockFromJson(Map<String, dynamic> json) {
  return TextBlock(
    text: json['text'] ?? '',
    boundingBox: _rectFromJson(json['boundingBox']),
    cornerPoints:
        (json['cornerPoints'] as List<dynamic>)
            .map((point) => _pointFromJson(point))
            .toList(),
    recognizedLanguages:
        (json['recognizedLanguages'] as List<dynamic>?)
            ?.map((lang) => lang.toString())
            .toList() ??
        [],
    lines:
        (json['lines'] as List<dynamic>)
            .map((line) => _textLineFromJson(line))
            .toList(),
  );
}

TextLine _textLineFromJson(Map<String, dynamic> json) {
  return TextLine(
    text: json['text'] ?? '',
    boundingBox: _rectFromJson(json['boundingBox']),
    cornerPoints:
        (json['cornerPoints'] as List<dynamic>)
            .map((point) => _pointFromJson(point))
            .toList(),
    recognizedLanguages:
        (json['recognizedLanguages'] as List<dynamic>?)
            ?.map((lang) => lang.toString())
            .toList() ??
        [],
    elements:
        (json['elements'] as List<dynamic>)
            .map((element) => _textElementFromJson(element))
            .toList(),
    confidence: null,
    angle: null,
  );
}

TextElement _textElementFromJson(Map<String, dynamic> json) {
  return TextElement(
    text: json['text'] ?? '',
    boundingBox: _rectFromJson(json['boundingBox']),
    cornerPoints:
        (json['cornerPoints'] as List<dynamic>)
            .map((point) => _pointFromJson(point))
            .toList(),
    symbols: [],
    recognizedLanguages: [],
    confidence: null,
    angle: null,
  );
}

Rect _rectFromJson(Map<String, dynamic> json) {
  return Rect.fromLTRB(
    (json['left'] as num).toDouble(),
    (json['top'] as num).toDouble(),
    (json['right'] as num).toDouble(),
    (json['bottom'] as num).toDouble(),
  );
}

Point<int> _pointFromJson(Map<String, dynamic> json) {
  return Point<int>((json['x'] as num).toInt(), (json['y'] as num).toInt());
}

RecognizedText getTextFromJson(String jsonString) {
  final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
  return recognizedTextFromJson(jsonMap);
}

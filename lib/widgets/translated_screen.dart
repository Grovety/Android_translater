import 'package:flutter/material.dart';
import 'package:multilingual_app/widgets/translated_text_painter.dart';

class TranslatedScreen extends StatelessWidget {
  const TranslatedScreen({super.key, required this.painter});

  final TranslatedTextPainter painter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: painter);
  }
}

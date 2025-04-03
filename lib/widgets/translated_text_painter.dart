import 'dart:developer';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'helper.dart';

class TranslatedTextPainter extends CustomPainter {
  TranslatedTextPainter(this.recognizedText, this.ratio);

  final RecognizedText recognizedText;
  final double ratio;

  static const _baseColor = Colors.deepPurple;
  static const _textBackgroundColor = Colors.black87;
  static const _backgroundColor = Colors.transparent;
  static const _textColor = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(_backgroundColor, BlendMode.clear);
    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = _baseColor;

    final Paint background = Paint()..color = _textBackgroundColor;

    for (final textBlock in recognizedText.blocks) {
      final targetHeightPx =
          (textBlock.cornerPoints.last.y - textBlock.cornerPoints.first.y)
              .abs() /
          ratio;
      final maxWidthPx =
          (textBlock.cornerPoints.last.x - textBlock.cornerPoints.first.x)
              .abs() /
          ratio;

      final curFontSize = calculateFontSize(
        text: textBlock.text,
        targetHeightPx: targetHeightPx,
        maxWidthPx: maxWidthPx,
      );

      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: curFontSize + 5,
          textDirection: TextDirection.ltr,
        ),
      );
      builder.pushStyle(
        ui.TextStyle(color: _textColor, background: background),
      );
      builder.addText(textBlock.text);
      builder.pop();
      //
      final left = textBlock.cornerPoints.first.x / ratio;
      final top = (textBlock.cornerPoints.first.y) / ratio;
      final right = (textBlock.cornerPoints[1].x) / ratio;

      final List<Offset> cornerPoints = <Offset>[];
      for (final point in textBlock.cornerPoints) {
        double x = (point.x / ratio).toDouble();
        double y = (point.y / ratio).toDouble();

        cornerPoints.add(Offset(x, y));
      }

      // Add the first point to close the polygon
      cornerPoints.add(cornerPoints.first);
      canvas.drawPoints(PointMode.polygon, cornerPoints, paint);

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(width: (right - left).abs())),
        Offset(left, top),
      );
      // log('------------------------Text data------------------------');
      // log(
      //   'textBlock: ${textBlock.text}\nPoints: $cornerPoints, left: $left, top: $top, right: $right',
      // );
    }
    log('Custom paint done');
  }

  @override
  bool shouldRepaint(TranslatedTextPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}

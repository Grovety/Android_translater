import 'package:flutter/material.dart';

double calculateFontSize({
  required String text,
  required double targetHeightPx,
  required double maxWidthPx,
  TextStyle? baseStyle,
}) {
  final TextPainter painter = TextPainter(textDirection: TextDirection.ltr);

  double fontSize = 10;
  double step = 1;

  while (step > 0.1) {
    painter.text = TextSpan(
      text: text,
      style: (baseStyle ?? const TextStyle()).copyWith(fontSize: fontSize),
    );
    painter.layout(maxWidth: maxWidthPx);

    if (painter.height < targetHeightPx) {
      fontSize += step;
    } else {
      fontSize -= step;
      step /= 2;
    }
  }

  // log('fontSize: $fontSize');

  return fontSize;
}

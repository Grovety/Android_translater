import 'package:multilingual_app/services/services.dart';

extension StringTranslateExtension on String {
  String tr() => l10n.getTranslation(this);
}

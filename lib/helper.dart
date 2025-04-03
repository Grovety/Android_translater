export 'package:google_mlkit_translation/google_mlkit_translation.dart';
export 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

export 'package:multilingual_app/api/api.dart';
export 'package:multilingual_app/services/services.dart';
export 'package:multilingual_app/ports/ports.dart';
export 'package:multilingual_app/services/localisation/l10n_translator.dart';

export 'dart:developer';

enum MessageSource { app, overlay }

enum Messages { translate, close, maximize, minimize, error, baseState }

import 'package:get_it/get_it.dart';

import 'recognition/google_text_recognition_api.dart';
import 'google_translation_api.dart';
import 'media_projection_api/media_projection_api.dart';

export 'package:multilingual_app/api/google_translation_api.dart';
export 'package:multilingual_app/api/media_projection_api/media_projection_api.dart';
export 'package:multilingual_app/api/recognition/google_text_recognition_api.dart';
export 'package:multilingual_app/api/recognition/helper.dart';

GoogleTranslationApi get translationApi => GetIt.I.get<GoogleTranslationApi>();
GoogleTextRecognitionApi get recognitionApi =>
    GetIt.I.get<GoogleTextRecognitionApi>();
MediaProjectionApi get mediaProjectionApi => GetIt.I.get<MediaProjectionApi>();

void registerApi() {
  GetIt.I.registerSingleton<GoogleTranslationApi>(GoogleTranslationApi());
  GetIt.I.registerSingleton<GoogleTextRecognitionApi>(
    GoogleTextRecognitionApi(),
  );
  GetIt.I.registerSingleton<MediaProjectionApi>(MediaProjectionApi());
}

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class GoogleTranslationApi {
  OnDeviceTranslator? createTranslator(
    String bcpSourceLanguage,
    String bcpTargetLanguage,
  ) {
    final TranslateLanguage? sourceLanguage = BCP47Code.fromRawValue(
      bcpSourceLanguage,
    );
    final TranslateLanguage? targetLanguage = BCP47Code.fromRawValue(
      bcpTargetLanguage,
    );

    if (sourceLanguage != null && targetLanguage != null) {
      return OnDeviceTranslator(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    }
    return null;
  }

  Future<void> closeTranslator(OnDeviceTranslator translator) async =>
      await translator.close();

  Future<String> translate(String text, OnDeviceTranslator translator) async =>
      await translator.translateText(text);

  Future<bool> checkModel(String bcpLanguage) async {
    final languageModelManager = OnDeviceTranslatorModelManager();
    final String? language = BCP47Code.fromRawValue(bcpLanguage)?.name;
    if (language != null) {
      bool isModelDownloaded = await languageModelManager.isModelDownloaded(
        bcpLanguage,
      );
      return isModelDownloaded;
    }
    return false;
  }
}

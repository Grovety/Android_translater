import 'package:get_it/get_it.dart';

import 'localisation/l10n.dart';
import 'overlay_service.dart';

export 'package:multilingual_app/services/overlay_service.dart';
export 'package:multilingual_app/services/translate_screen_text.dart';
export 'package:multilingual_app/services/localisation/l10n.dart';

OverlayService get overlayService => GetIt.I.get<OverlayService>();

L10n get l10n => GetIt.I.get<L10n>();

void registerServices() {
  GetIt.I.registerSingleton<OverlayService>(OverlayService());
  GetIt.I.registerSingleton<L10n>(L10n());
}

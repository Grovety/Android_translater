import 'package:get_it/get_it.dart';

import 'app_ports.dart';

export 'package:multilingual_app/ports/app_ports.dart';

AppPorts get appPorts => GetIt.I.get<AppPorts>();

void registerPorts() {
  GetIt.I.registerSingleton<AppPorts>(AppPorts());
}

import 'package:flutter/material.dart';

import 'package:multilingual_app/widgets/home_screen.dart';
import 'package:multilingual_app/widgets/overlay_screen.dart';

import 'package:multilingual_app/helper.dart';

void registerInstances() {
  registerApi();
  registerServices();
  registerPorts();
}

void main() {
  registerInstances();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  registerPorts();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: OverlayScreen()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: l10n.loadTranslations(),
      builder: (ctx, snapshot) => HomeScreen(isLoaded: snapshot.hasData),
    );
  }
}

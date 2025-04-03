import 'package:flutter/material.dart';
import 'package:multilingual_app/services/localisation/l10n_translator.dart';

import 'text_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.isLoaded});

  final bool isLoaded;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: isLoaded ? Text('app_name'.tr()) : null,
        ),
        body:
            isLoaded
                ? const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[TextView()],
                )
                : Center(child: const CircularProgressIndicator()),
      ),
    );
  }
}

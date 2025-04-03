import 'package:flutter/material.dart';
import 'package:multilingual_app/helper.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late List<String> _languageList;
  late Widget _languageWidget;
  bool _isChoosingLanguage = false;

  @override
  void initState() {
    super.initState();
    _languageList = _createLanguageList();
    _createSourceLanguageWidget();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('settings_button'.tr()),
      content: SizedBox(
        height: 100,
        child: ListView(
          children: [
            GestureDetector(onTap: _chooseLanguage, child: _languageWidget),
            SizedBox(height: 15),
            Text('${'target_lan'.tr()}: ${L10n.curTargetLanguage}'),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        ElevatedButton(
          child: Text('close'.tr()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _createSourceLanguageWidget() =>
      _languageWidget =
          _isChoosingLanguage
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFf0edf0),
                ),
                child: ListView.builder(
                  itemCount: _languageList.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder:
                      (BuildContext context, int index) => TextButton(
                        onPressed:
                            () => _updateSourceLanguage(_languageList[index]),
                        child: Text(_languageList[index]),
                      ),
                ),
              )
              : Text('${'source_lan'.tr()}: ${L10n.curSourceLanguage}');

  void _chooseLanguage() {
    _isChoosingLanguage = !_isChoosingLanguage;
    _createSourceLanguageWidget();
    setState(() {});
  }

  List<String> _createLanguageList() =>
      TranslateLanguage.values.map((language) => language.bcpCode).toList();

  void _updateSourceLanguage(String language) {
    l10n.updateSourceLanguage(language);
    Navigator.of(context).pop();
  }
}

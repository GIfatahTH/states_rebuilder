import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../common/localization/languages/language_base.dart';
import '../../common/localization/localization.dart';

class Languages extends StatelessWidget {
  const Languages();
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      onSelected: (l) {
        i18n.locale = l;
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<Locale>>[
        PopupMenuItem<Locale>(
          key: Key('__System_language__'),
          value: const SystemLocale(),
          child: Text(
            i18n.of(context).systemLanguage,
          ),
        ),
        ...i18n.supportedLocales.map(
          (e) => PopupMenuItem<Locale>(
            value: e,
            child: Text(
              e.languageCode.toUpperCase(),
            ),
          ),
        ),
      ],
      icon: const Icon(Icons.language),
    );
  }
}

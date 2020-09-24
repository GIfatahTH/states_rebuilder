import 'package:flutter/material.dart';

import '../../common/localization/languages/language_base.dart';
import '../../common/localization/localization.dart';

class Languages extends StatelessWidget {
  const Languages();
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      onSelected: (l) {
        locale.state = l;
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale.fromSubtags(
            languageCode: 'und',
          ),
          child: Text(
            i18n.state.systemLanguage,
          ),
        ),
        ...I18N.supportedLocale.map(
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

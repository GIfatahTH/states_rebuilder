import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'languages/ar.dart';
import 'languages/language_base.dart';

final i18n = RM.injectI18N(
  {
    Locale.fromSubtags(languageCode: 'en'): EN(),
    Locale.fromSubtags(languageCode: 'ar'): AR(),
    Locale.fromSubtags(languageCode: 'fr'): FR(),
  },
  persistKey: '__locale__',
);

class FR extends EN {
  @override
  String get appTitle => 'Francais';
}

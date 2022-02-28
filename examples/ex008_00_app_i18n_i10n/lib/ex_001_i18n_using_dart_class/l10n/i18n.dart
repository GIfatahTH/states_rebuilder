import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'app_ar.dart';
import 'app_en.dart';
import 'app_es.dart';

final i18nRM = RM.injectI18N<AppLocalizations>(
  {
    const Locale('en'): () => AppLocalizationsEn(),
    const Locale('ar'): () => AppLocalizationsAr(),
    const Locale('es'): () => AppLocalizationsEs(),
  },
  sideEffects: SideEffects.onData(
    (data) => RM.scaffold.showSnackBar(
      SnackBar(
        content: Text(data.helloWorld),
      ),
    ),
  ),
);

abstract class AppLocalizations {
  String get helloWorld;
  String welcome(Object name);
  String gender(Object gender);
  String plural(num howMany);
  String formattedNumber(int value);
  String date(DateTime date);
}

import 'package:material_ui/material_ui.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

import 'app_localizations.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

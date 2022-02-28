import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_es.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

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

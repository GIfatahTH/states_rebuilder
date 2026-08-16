import 'package:states_rebuilder/states_rebuilder.dart';
import 'app_localizations.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

final i18nRM = RM.injectI18N<AppLocalizations>({
  'en'.locale(): () => AppLocalizationsEn(),
  'ar'.locale(): () => AppLocalizationsAr(),
  'es'.locale(): () => AppLocalizationsEs(),
});

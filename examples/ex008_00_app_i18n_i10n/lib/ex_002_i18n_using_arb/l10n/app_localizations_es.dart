// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get helloWorld => '¡Hola Mundo!';

  @override
  String welcome(Object name) {
    return 'Hola $name';
  }

  @override
  String gender(String gender) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'Hola el hombre',
        'female': 'Hola la mujer',
        'other': 'Hola',
      },
    );
    return '$_temp0';
  }

  @override
  String plural(num howMany) {
    String _temp0 = intl.Intl.pluralLogic(
      howMany,
      locale: localeName,
      other: '$howMany mensajes',
      one: '1 mensaje',
    );
    return '$_temp0';
  }

  @override
  String formattedNumber(int value) {
    final intl.NumberFormat valueNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String valueString = valueNumberFormat.format(value);

    return 'El número formateado es: $valueString';
  }

  @override
  String date(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Es $dateString';
  }
}

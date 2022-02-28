import 'package:intl/intl.dart' as intl;
import 'i18n.dart';

class AppLocalizationsEs extends AppLocalizations {
  final String localeName = 'es';

  @override
  String get helloWorld => '¡Hola Mundo!';

  @override
  String welcome(Object name) {
    return 'Hola $name';
  }

  @override
  String gender(Object gender) {
    return intl.Intl.select(gender,
        {'male': 'Hola el hombre', 'female': 'Hola la mujer', 'other': 'Hola'},
        desc: 'No description provided in @gender');
  }

  @override
  String plural(num howMany) {
    return intl.Intl.pluralLogic(
      howMany,
      locale: localeName,
      one: '1 mensaje',
      other: '$howMany mensajes',
    );
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

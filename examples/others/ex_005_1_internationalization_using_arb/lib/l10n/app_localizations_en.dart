// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String welcome(Object name) {
    return 'Welcome $name';
  }

  @override
  String gender(String gender) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'Hi man!',
        'female': 'Hi woman!',
        'other': 'Hi there!',
      },
    );
    return '$_temp0';
  }

  @override
  String plural(num howMany) {
    String _temp0 = intl.Intl.pluralLogic(
      howMany,
      locale: localeName,
      other: '$howMany messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String formattedNumber(int value) {
    final intl.NumberFormat valueNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String valueString = valueNumberFormat.format(value);

    return 'The formatted number is: $valueString';
  }

  @override
  String date(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'It is $dateString';
  }
}

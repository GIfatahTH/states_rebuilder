import 'package:intl/intl.dart' as intl;
import 'i18n.dart';

class AppLocalizationsEn implements AppLocalizations {
  final String localeName = 'en';
  @override
  String get helloWorld => 'Hello World!';

  @override
  String welcome(Object name) {
    return 'Welcome $name';
  }

  @override
  String gender(Object gender) {
    return intl.Intl.select(gender,
        {'male': 'Hi man!', 'female': 'Hi woman!', 'other': 'Hi there!'},
        desc: 'No description provided in @gender');
  }

  @override
  String plural(num howMany) {
    return intl.Intl.pluralLogic(
      howMany,
      locale: localeName,
      one: '1 message',
      other: '$howMany messages',
    );
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

import 'package:intl/intl.dart' as intl;
import 'i18n.dart';

class AppLocalizationsAr extends AppLocalizations {
  final String localeName = 'ar';

  @override
  String get helloWorld => 'مرحبا بالجميع!';

  @override
  String welcome(Object name) {
    return 'مرحبا $name';
  }

  @override
  String gender(Object gender) {
    return intl.Intl.select(
        gender,
        {
          'male': 'مرحبا يارجل!',
          'female': 'مرحبا يامرأة!',
          'other': 'مرحبا هناك!'
        },
        desc: 'No description provided in @gender');
  }

  @override
  String plural(num howMany) {
    return intl.Intl.pluralLogic(
      howMany,
      locale: localeName,
      zero: 'صفر رسالة',
      one: 'رسالة واحدة',
      few: '$howMany رسائل',
      other: '$howMany رسالة',
    );
  }

  @override
  String formattedNumber(int value) {
    final intl.NumberFormat valueNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String valueString = valueNumberFormat.format(value);

    return 'الرقم بعد التهيئة هو $valueString';
  }

  @override
  String date(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'اليوم هو $dateString';
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get helloWorld => 'مرحبا بالجميع!';

  @override
  String welcome(Object name) {
    return 'مرحبا $name';
  }

  @override
  String gender(String gender) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'مرحبا يارجل!',
        'female': 'مرحبا يامرأة!',
        'other': 'مرحبا هناك!',
      },
    );
    return '$_temp0';
  }

  @override
  String plural(num howMany) {
    String _temp0 = intl.Intl.pluralLogic(
      howMany,
      locale: localeName,
      other: '$howMany رسالة',
      few: '$howMany رسائل',
      two: 'رسالاتان',
      one: 'رسالة واحدة',
      zero: 'صفر رسالة',
    );
    return '$_temp0';
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

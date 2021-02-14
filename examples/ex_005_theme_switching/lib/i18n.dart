import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final i18n = RM.injectI18N<EnUS>(
  {
    Locale('en', 'US'): () => EnUS(),
    Locale('es', 'ES'): () => EsES(),
    Locale('ar', 'DZ'): () => ArDZ(),
    Locale('fr', 'FR'): () =>
        Future.delayed(Duration(seconds: 1), () => FrFR()),
  },
  persistKey: '__lang__',
  debugPrintWhenNotifiedPreMessage: '',
  onSetState: On.data(() {
    //Wait until the next frame to ensure BuildContext is valid and
    //snackBar is displayed properly for French language as it is async
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //For better user experience, RTL languages page animates from RTL
      if (Directionality.of(RM.context) == TextDirection.rtl) {
        RM.navigate.transitionsBuilder = Transitions.rightToLeft();
      } else {
        RM.navigate.transitionsBuilder = Transitions.leftToRight();
      }

      RM.scaffold.showSnackBar(
        SnackBar(
          content: Text(
            //Get the current translation without BuildContext
            i18n.state.helloWold,
          ),
        ),
      );
    });
  }),
);

class EnUS {
  final helloWold = 'Hello World';
  final flutterDemo = 'flutter_demo';
  final preferences = 'Preferences';
  final home = 'Home';
  final greenTheme = 'Green Theme';
  final blueTheme = 'Blue Theme';
  final toggleDarkMode = 'Toggle Dark mode';
  final useSystemMode = 'Use system mode';
  final systemLanguage = 'System Language';
  //
  String counterTimes(int count) {
    if (count == 0) {
      return 'Zero times';
    }
    if (count == 1) {
      return 'One time';
    }
    return '$count times';
  }
}

class EsES implements EnUS {
  final helloWold = 'Hola mondo';
  final flutterDemo = 'flutter_demo';
  final preferences = 'Preferencias';
  final home = 'Página de inicio';
  final greenTheme = 'Tema verde';
  final blueTheme = 'Tema azul';
  final toggleDarkMode = 'cambiar al modo oscuro ';
  final useSystemMode = 'Usar el modo de sistema ';
  final systemLanguage = 'Lenguaje del sistema';
  //
  String counterTimes(int count) {
    if (count == 0) {
      return 'Cero veces';
    }
    if (count == 1) {
      return 'Una vez';
    }
    return '$count veces';
  }
}

class FrFR implements EnUS {
  final helloWold = 'Bonjour le monde';
  final flutterDemo = 'flutter_demo';
  final preferences = 'Préférences';
  final home = 'Page d\'accueil';
  final greenTheme = 'Thème vert';
  final blueTheme = 'Thème bleu';
  final toggleDarkMode = 'Basculer en mode sombre';
  final useSystemMode = 'Utiliser le mode du système';
  final systemLanguage = 'La Langue du système';

  //
  String counterTimes(int count) {
    if (count == 0) {
      return 'Zero fois';
    }
    if (count == 1) {
      return 'Une fois';
    }
    return '$count fois';
  }
}

class ArDZ implements EnUS {
  final helloWold = 'مرحبا بالعالم';
  final flutterDemo = 'تجربة فلاتر';
  final preferences = 'إعدادات';
  final home = 'صفحة البداية';
  final greenTheme = 'نسق الألوان الاخضر';
  final blueTheme = 'نسق الألوان الازرق';
  final toggleDarkMode = 'تبديل النمط الداكن';
  final useSystemMode = 'استعمل نمط النظام';
  final systemLanguage = 'لغة النظام';

  //
  String counterTimes(int count) {
    if (count == 0) {
      return 'صفر مرة';
    }
    if (count == 1) {
      return 'مرة واحدة';
    }
    if (count == 2) {
      return 'مرتان';
    }
    if (count <= 10) {
      return '$count مرات';
    }
    return '$count مرة';
  }
}

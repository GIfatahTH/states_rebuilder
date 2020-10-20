import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'hive.dart';
import 'shared_preference.dart';
import 'sqflite.dart';
import 'ui/common/localization/languages/language_base.dart';
import 'ui/common/localization/localization.dart';
import 'ui/common/theme/theme.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/home_screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await RM.storageInitializer(SharedPreferencesImp());
  await RM.storageInitializer(HiveImp());
  // await RM.storageInitializer(SqfliteImp());

  runApp(
    StateWithMixinBuilder.widgetsBindingObserver(
      didChangeLocales: (context, locales) {
        if (locale.state.languageCode == 'und') {
          locale.state = locales.first;
        }
      },
      builder: (_, __) => App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return [isDarkMode, locale].whenRebuilderOr(
      //If any of isDarkModel or locale is getting data from async task, wait for it
      onWaiting: () => const Center(
        child: const CircularProgressIndicator(),
      ),
      builder: () {
        return i18n.inherited(
          builder: (context) => MaterialApp(
            //Get the i18n translation using the of(context) method
            title: i18n.of(context).appTitle,
            theme: isDarkMode.state ? ThemeData.dark() : ThemeData.light(),
            locale: locale.state.languageCode == 'und' ? null : locale.state,
            supportedLocales: I18N.supportedLocale,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            routes: {
              //Notice const here and everywhere in this app.
              // This is a huge benefit in performance term.
              AddEditPage.routeName: (context) => const AddEditPage(),
              HomeScreen.routeName: (context) => const HomeScreen(),
            },
            navigatorKey: RM.navigate.navigatorKey,
          ),
        );
      },
    );
  }
}

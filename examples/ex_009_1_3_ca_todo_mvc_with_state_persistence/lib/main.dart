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

  // await RM.localStorageInitializer(SharedPreferencesImp());
  await RM.localStorageInitializer(HiveImp());
  // await RM.localStorageInitializer(SqfliteImp());

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
      onWaiting: () => const Center(
        child: const CircularProgressIndicator(),
      ),
      builder: () {
        return MaterialApp(
          key: UniqueKey(),
          title: i18n.state.appTitle,
          theme: isDarkMode.state ? ThemeData.dark() : ThemeData.light(),
          locale: locale.state.languageCode == 'und' ? null : locale.state,
          supportedLocales: I18N.supportedLocale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          routes: {
            AddEditPage.routeName: (context) => const AddEditPage(),
            HomeScreen.routeName: (context) => const HomeScreen(),
          },
          navigatorKey: RM.navigate.navigatorKey,
        );
      },
    );
  }
}

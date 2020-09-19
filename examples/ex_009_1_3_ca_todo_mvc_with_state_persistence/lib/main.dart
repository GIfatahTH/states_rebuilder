import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import './ui/common/localization/localization.dart';
import './ui/common/theme/theme.dart';
import 'shared_preference.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/home_screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RM.localStorageInitializer(SharedPreferencesImp());

  runApp(App());
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
          title: i18n.state.appTitle,
          theme: isDarkMode.state ? ThemeData.dark() : ThemeData.light(),
          locale: locale.state,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          routes: {
            AddEditPage.routeName: (context) => AddEditPage(),
            HomeScreen.routeName: (context) => HomeScreen(),
          },
          navigatorKey: RM.navigate.navigatorKey,
        );
      },
    );
  }
}

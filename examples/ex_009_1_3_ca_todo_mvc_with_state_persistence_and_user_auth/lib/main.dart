import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/data_source/firebase_todos_repository.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/user.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'hive.dart';
import 'injected.dart';
import 'shared_preference.dart';
import 'sqflite.dart';
import 'ui/common/localization/languages/language_base.dart';
import 'ui/common/localization/localization.dart';
import 'ui/common/theme/theme.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/auth_page/auth_page.dart';
import 'ui/pages/home_screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await RM.localStorageInitializer(SharedPreferencesImp());
  await RM.localStorageInitializer(HiveImp());
  // await RM.localStorageInitializer(SqfliteImp());
  // await RM.localStorageInitializer(FireBaseTodosRepository());

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
          title: i18n.state.appTitle,
          theme: isDarkMode.state ? ThemeData.dark() : ThemeData.light(),
          locale: locale.state.languageCode == 'und' ? null : locale.state,
          supportedLocales: I18N.supportedLocale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: user.whenRebuilderOr(
            onWaiting: () => SplashScreen(),
            builder: () =>
                user.state is UnsignedUser ? AuthPage() : HomeScreen(),
          ),
          routes: {
            // SplashScreen.routeName: (context) => SplashScreen(),
            HomeScreen.routeName: (context) => const HomeScreen(),
            AuthPage.routeName: (context) => const AuthPage(),
            AddEditPage.routeName: (context) => const AddEditPage(),
          },
          navigatorKey: RM.navigate.navigatorKey,
        );
      },
    );
  }
}

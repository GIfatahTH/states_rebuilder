import 'ui/injected/injected_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'hive.dart';
import 'ui/common/localization/languages/language_base.dart';
import 'ui/common/localization/localization.dart';
import 'ui/common/theme/theme.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/auth_page/auth_page.dart';
import 'ui/pages/home_screen/home_screen.dart';
import 'ui/widgets/splash_screen.dart';

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
      onWaiting: () => const Center(
        child: const CircularProgressIndicator(),
      ),
      //As user is not autoDisposed, we dispose it manually here.
      dispose: () => user.dispose(),
      builder: () {
        return i18n.inherited(
          builder: (context) => MaterialApp(
            title: i18n.of(context).appTitle,
            theme: isDarkMode.state ? ThemeData.dark() : ThemeData.light(),
            locale: locale.state.languageCode == 'und' ? null : locale.state,
            supportedLocales: I18N.supportedLocale,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            //First await for the user to auto authenticate
            home: user.futureBuilder(
              //Display a splashScreen while authenticating
              onWaiting: () => SplashScreen(),
              //On Error display the authPage and a Snackbar with the error as defined
              //in onError callback of the user injected model.
              onError: (_) => AuthPage(),

              // **If you do not want to use navigation, uncomment this**
              //To be able to logout and display the AuthPage again we register to user model
              // onData: (_) => user.rebuilder(
              //   () => user.state is UnsignedUser
              //       ? const AuthPage()
              //       : const HomeScreen(),
              // ),
              onData: (_) => Container(),
            ),
            routes: {
              HomeScreen.routeName: (context) => const HomeScreen(),
              AuthPage.routeName: (context) => const AuthPage(),
              AddEditPage.routeName: (context) => const AddEditPage(),
            },
            navigatorKey: RM.navigate.navigatorKey,
          ),
        );
      },
    );
  }
}

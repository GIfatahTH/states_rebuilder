import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/data_source/hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'ui/common/localization/localization.dart';
import 'ui/common/theme/theme.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/auth_page/auth_page.dart';
import 'ui/pages/home_screen/home_screen.dart';
import 'ui/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RM.storageInitializer(HiveStorage());
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print(context);
    return TopAppWidget(
      waiteFor: () => [
        //   RM.storageInitializer(HiveStore()),
      ],
      onWaiting: () => MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      onError: (error, refresh) {
        return Text('error');
      },
      injectedTheme: isDark,
      injectedI18N: i18n,
      injectedAuth: user,
      builder: (context) {
        print(context);
        return MaterialApp(
          title: i18n.of(context).appTitle,
          //theme
          theme: isDark.lightTheme,
          darkTheme: isDark.darkTheme,
          themeMode: isDark.themeMode,
          //i18n
          locale: i18n.locale,
          localeResolutionCallback: i18n.localeResolutionCallback,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: SplashScreen(),
          routes: {
            HomeScreen.routeName: (context) => const HomeScreen(),
            AuthPage.routeName: (context) => const AuthPage(),
            AddEditPage.routeName: (context) => const AddEditPage(),
          },
          navigatorKey: RM.navigate.navigatorKey,
        );
      },
    );
  }

  // Widget build(BuildContext context) {
  //   return [isDark as Injected].whenRebuilderOr(
  //     onWaiting: () => const Center(
  //       child: const CircularProgressIndicator(),
  //     ),
  //     //As user is not autoDisposed, we dispose it manually here.
  //     dispose: () => user.dispose(),
  //     builder: () {
  //       return i18n.inherited(
  //         builder: (context) => MaterialApp(
  //           title: i18n.of(context).appTitle,
  //           theme: isDark.lightTheme,
  //           darkTheme: isDark.darkTheme,
  //           themeMode: isDark.themeMode,
  //           locale: i18n.locale,
  //           supportedLocales: i18n.supportedLocales,
  //           localizationsDelegates: [
  //             GlobalMaterialLocalizations.delegate,
  //             GlobalWidgetsLocalizations.delegate,
  //           ],
  //           //First await for the user to auto authenticate
  //           home: user.futureBuilder(
  //             //Display a splashScreen while authenticating
  //             onWaiting: null,
  //             //On Error display the authPage and a Snackbar with the error as defined
  //             //in onError callback of the user injected model.
  //             onError: (_) => AuthPage(),

  //             // **If you do not want to use navigation, uncomment this**
  //             //To be able to logout and display the AuthPage again we register to user model
  //             // onData: (_) => user.rebuilder(
  //             //   () => user.state is UnsignedUser
  //             //       ? const AuthPage()
  //             //       : const HomeScreen(),
  //             // ),
  //             onData: (_) {
  //               return SplashScreen();
  //             },
  //           ),
  //           routes: {
  //             HomeScreen.routeName: (context) => const HomeScreen(),
  //             AuthPage.routeName: (context) => const AuthPage(),
  //             AddEditPage.routeName: (context) => const AddEditPage(),
  //           },
  //           navigatorKey: RM.navigate.navigatorKey,
  //         ),
  //       );
  //     },
  //   );
  // }
}

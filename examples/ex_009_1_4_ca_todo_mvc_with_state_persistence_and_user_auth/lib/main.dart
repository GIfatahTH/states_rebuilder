import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/data_source/hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'ui/common/localization/localization.dart';
import 'ui/common/theme/theme.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/auth_page/auth_page.dart';
import 'ui/pages/home_screen/home_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await RM.storageInitializer(HiveStorage());
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TopAppWidget(
      waiteFor: () => [
        RM.storageInitializer(HiveStorage()),
      ],
      onWaiting: () => MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Container(),
        ),
      ),
      onError: (error, refresh) {
        return Text('error');
      },
      injectedTheme: isDark,
      injectedI18N: i18n,
      builder: (context) {
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
          home: On.auth(
            onUnsigned: () => AuthPage(),
            onSigned: () => HomeScreen(),
          ).listenTo(
            user,
            useRouteNavigation: true,
          ),
          navigatorKey: RM.navigate.navigatorKey,
          onGenerateRoute: RM.navigate.onGenerateRoute(
            {
              HomeScreen.routeName: (_) => const HomeScreen(),
              AuthPage.routeName: (_) => const AuthPage(),
              AddEditPage.routeName: (_) => const AddEditPage(),
            },
            // transitionsBuilder: RM.transitions.upToBottom(),
          ),
        );
      },
    );
  }
}

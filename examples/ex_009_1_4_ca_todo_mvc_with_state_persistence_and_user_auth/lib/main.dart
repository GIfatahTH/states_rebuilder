import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/blocs/auth_bloc.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/data_source/hive_storage.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/localization/localization.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/auth_page/auth_page.dart';
import 'ui/pages/home_screen/home_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await RM.storageInitializer(HiveStorage());
  runApp(App());
}

class App extends TopStatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  List<Future<void>>? ensureInitialization() {
    return [
      RM.storageInitializer(HiveStorage()),
    ];
  }

  @override
  Widget? splashScreen() {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Container(),
      ),
    );
  }

  @override
  Widget? errorScreen(error, void Function() refresh) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Text('$error'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: i18n.state.appTitle,
      // theme
      theme: isDark.lightTheme,
      darkTheme: isDark.darkTheme,
      themeMode: isDark.themeMode,
      // i18n
      locale: i18n.locale,
      localeResolutionCallback: i18n.localeResolutionCallback,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: OnAuthBuilder(
        listenTo: authBloc.userRM,
        onInitialWaiting: () => Center(child: CircularProgressIndicator()),
        onUnsigned: () => AuthPage(),
        onSigned: () => HomeScreen(),
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
  }
}

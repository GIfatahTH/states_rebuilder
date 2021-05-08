import 'package:ex_005_theme_switching/hive_storage.dart';

import 'i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'home_page.dart';
import 'themes.dart';

void main() async {
  //Plugins can initialized in the TopAppWidget
  // WidgetsFlutterBinding.ensureInitialized();
  // await RM.storageInitializer(HiveStorage());
  RM.navigate.transitionsBuilder = RM.transitions.leftToRight();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopAppWidget(
      ensureInitialization: () => [
        //Plugins can be initialized, to display our Splash screen
        RM.storageInitializer(HiveStorage()),
      ],
      injectedTheme: theme,
      injectedI18N: i18n,
      onWaiting: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          //Defining locale and localeResolutionCallback is enough to
          //handle the app localization
          locale: i18n.locale,
          localeResolutionCallback: i18n.localeResolutionCallback,
          //For more elaborate locale resolution algorithm use supportedLocales and
          //localeListResolutionCallback.
          // supportedLocales: i18n.supportedLocales,
          // localeListResolutionCallback: (List<Locale>? locales, Iterable<Locale> supportedLocales){
          //   //your algorithm
          //   } ,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          title: i18n.of(context).flutterDemo,
          home: const HomePage(),
          navigatorKey: RM.navigate.navigatorKey,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';

import 'localization.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/home_screen/home_screen.dart';

class StatesRebuilderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: StatesRebuilderLocalizations().appTitle,
      theme: ArchSampleTheme.theme,
      localizationsDelegates: [
        ArchSampleLocalizationsDelegate(),
        StatesRebuilderLocalizationsDelegate(),
      ],
      routes: {
        ArchSampleRoutes.home: (context) => HomeScreen(),
        ArchSampleRoutes.addTodo: (context) => AddEditPage(),
      },
    );
  }
}

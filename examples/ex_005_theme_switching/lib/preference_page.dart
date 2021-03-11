import 'i18n.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'themes.dart';

class PreferencePage extends StatelessWidget {
  const PreferencePage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.state.preferences),
        actions: [
          PopupMenuButton<Locale>(
            key: Key('_ChangeLanguage_'),
            onSelected: (value) {
              i18n.locale = value;
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: SystemLocale(),
                  child: Text(
                    i18n.of(context).systemLanguage,
                    style: TextStyle(
                      fontWeight: i18n.locale is SystemLocale
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                ...i18n.supportedLocales.map(
                  (e) => PopupMenuItem(
                    value: e,
                    child: Text(
                      '$e',
                      style: TextStyle(
                        fontWeight: i18n.locale == e
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                )
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              color: theme.supportedLightThemes[AppTheme.Green].primaryColor,
              child: ListTile(
                title: Text(
                  i18n.of(context).greenTheme,
                  style: theme
                      .supportedLightThemes[AppTheme.Green].textTheme.bodyText2,
                ),
                onTap: () => theme.state = AppTheme.Green,
              ),
            ),
            Card(
              color: theme.supportedLightThemes[AppTheme.Blue].primaryColor,
              child: ListTile(
                key: Key('BlueThemeListTile'),
                title: Text(
                  i18n.of(context).blueTheme,
                  style: theme
                      .supportedLightThemes[AppTheme.Blue].textTheme.bodyText2,
                ),
                onTap: () => theme.state = AppTheme.Blue,
              ),
            ),
            On(
              () => Row(
                children: [
                  Text(i18n.of(context).toggleDarkMode),
                  SizedBox(width: 8),
                  if (theme.isDarkTheme)
                    Icon(Icons.nights_stay)
                  else
                    Icon(Icons.wb_sunny, color: Colors.yellow),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ).listenTo(theme),
            Row(
              children: [
                OutlineButton(
                  child: Text(i18n.of(context).useSystemMode),
                  onPressed: () {
                    theme.themeMode = ThemeMode.system;
                  },
                ),
                SizedBox(width: 8),
                On(
                  () => Switch(
                    value: theme.isDarkTheme,
                    onChanged: (_) => theme.toggle(),
                  ),
                ).listenTo(theme),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            )
          ],
        ),
      ),

      // ListView.builder(
      //   padding: EdgeInsets.all(8),
      //   itemCount: AppTheme.values.length,
      //   itemBuilder: (context, index) {
      //     final itemAppTheme = AppTheme.values[index];
      //     return ;
      //   },
      // ),
    );
  }
}

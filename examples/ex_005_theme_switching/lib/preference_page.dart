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
        title: Text(i18n.of(context).preferences),
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
                          ? FontWeight.w900
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
                            ? FontWeight.w900
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
        child: OnReactive(
          () => Column(
            children: [
              Card(
                color: theme.supportedLightThemes[AppTheme.Green].primaryColor,
                child: ListTile(
                  title: Text(
                    i18n.of(context).greenTheme,
                    style: theme.supportedLightThemes[AppTheme.Green].textTheme
                        .bodyText2,
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
                    style: theme.supportedLightThemes[AppTheme.Blue].textTheme
                        .bodyText2,
                  ),
                  onTap: () => theme.state = AppTheme.Blue,
                ),
              ),
              Row(
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
              Row(
                children: [
                  OutlinedButton(
                    child: Text(i18n.of(context).useSystemMode),
                    onPressed: () {
                      theme.themeMode = ThemeMode.system;
                    },
                  ),
                  SizedBox(width: 8),
                  Switch(
                    value: theme.isDarkTheme,
                    onChanged: (_) => theme.toggle(),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              )
            ],
          ),
          debugPrintWhenObserverAdd: '',
        ),
      ),
    );
  }
}

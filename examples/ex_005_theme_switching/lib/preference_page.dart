import 'package:flutter/material.dart';

import 'themes.dart';

class PreferencePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
        actions: [
          Icon(theme.isDarkTheme ? Icons.nights_stay : Icons.wb_sunny),
          Switch(
            value: theme.isDarkTheme,
            onChanged: (_) => theme.toggle(),
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: AppTheme.values.length,
        itemBuilder: (context, index) {
          final itemAppTheme = AppTheme.values[index];
          return Column(
            children: [
              Card(
                color: theme.supportedLightThemes[itemAppTheme].primaryColor,
                child: ListTile(
                  title: Text(
                    itemAppTheme.toString(),
                    style: theme
                        .supportedLightThemes[itemAppTheme].textTheme.bodyText2,
                  ),
                  onTap: () => theme.state = itemAppTheme,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

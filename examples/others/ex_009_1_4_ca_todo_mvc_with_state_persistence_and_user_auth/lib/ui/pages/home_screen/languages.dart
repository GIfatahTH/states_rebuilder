part of 'home_screen.dart';

class Languages extends StatelessWidget {
  const Languages();
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      onSelected: (l) {
        i18n.locale = l;
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<Locale>>[
        PopupMenuItem<Locale>(
          key: Key('__System_language__'),
          value: SystemLocale(),
          child: Text(
            i18n.of(context).systemLanguage,
          ),
        ),
        ...i18n.supportedLocales.map(
          (e) => PopupMenuItem<Locale>(
            value: e,
            child: Text(
              e.languageCode.toUpperCase(),
            ),
          ),
        ),
      ],
      icon: const Icon(Icons.language),
    );
  }
}

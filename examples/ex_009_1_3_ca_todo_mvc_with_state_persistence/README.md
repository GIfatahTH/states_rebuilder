# ex_009_1_3_ca_todo_mvc_with_state_persistence

With this example, we will feel the true power of states_rebuilder with global function injection.

The example consist of the Todo MVC app extended to handle dynamic theme and internationalization.

## Setting persistance provider

As we want to persist the chosen theme and language as well as the todos list, we start by setting the persistance provider.

with states_rebuilder, you have the freedom of choosing your storage provider. All you need to do is to implement the `IPersistStore` interface

### SharedPreferences:
```dart

class SharedPreferencesImp implements IPersistStore {
  SharedPreferences _sharedPreferences;

  @override
  Future<void> init() async {
    //Initialize the plugging
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Object read(String key) {
    try {
      return _sharedPreferences.getString(key);
    } catch (e) {
      //throw a costume exceptions
      throw PersistanceException('There is a problem in reading $key: $e');
    }
  }

  @override
  Future<void> write<T>(String key, T value) async {
    try {
      return _sharedPreferences.setString(key, value as String);
    } catch (e) {
    //throw a costume exceptions
      throw PersistanceException('There is a problem in writing $key: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    return _sharedPreferences.remove(key);
  }

  @override
  Future<void> deleteAll() {
    return _sharedPreferences.clear();
  }
}
```

### Hive:
```dart
class HiveImp implements IPersistStore {
  Box box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('myBox');
  }

  @override
  Object read(String key) {
    try {
      return box.get(key);
    } catch (e) {
      throw PersistanceException('There is a problem in reading $key: $e');
    }
  }

  @override
  Future<void> write<T>(String key, T value) async {
    try {
      return box.put(key, value);
    } catch (e) {
      throw PersistanceException('There is a problem in writing $key: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    return box.delete(key);
  }

  @override
  Future<void> deleteAll() async {
    return box.clear();
  }
}
```

### Sqflite:
```dart
class SqfliteImp implements IPersistStore {
  Database _db;
  final _tableName = 'AppStorage';

  @override
  Future<void> init() async {
    final databasesPath =
        await path_provider.getApplicationDocumentsDirectory();
    _db = await openDatabase(
      join(databasesPath.path, 'todo_db.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE $_tableName (key TEXT PRIMARY KEY, value TEXT)',
        );
      },
    );
  }

  @override
  Object read(String key) async {
    try {
      final result = await _db.query(
        _tableName,
        where: 'key = ?',
        whereArgs: [key],
      );
      if (result.isNotEmpty) {
        return result.first['value'];
      }
      return null;
    } catch (e) {
      throw PersistanceException('There is a problem in reading $key: $e');
    }
  }

  @override
  Future<void> write<T>(String key, T value) async {
    try {
      return await _db.insert(
        _tableName,
        {
          'key': key,
          'value': value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw PersistanceException('There is a problem in writing $key: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    return _db.delete(_tableName, where: 'key = $key');
  }

  @override
  Future<void> deleteAll() async {
    return _db.delete(_tableName);
  }
}
```

## Theme
As we want to switch between dark and light mode, we inject and persist a boolean value to track whether we have chosen dart or not.
```dart
final isDarkMode = RM.inject<bool>(
  () => true,
  //Show our intention to persist the state by defining the persist parameter
  persist: () => PersistState(
    //Give it a unique key.
    key: '__themeData__',
    //Tell how to transition from json to state and the opposite.
    //Our case is simple:
    //'1' is true, and '0' is false
    fromJson: (json) => json == '1',
    toJson: (themeData) => themeData ? '1' : '0',
  ),
);
```
That's all for the business logic part. In the UI  can register to the injected isDarkMode and change its state.


[Refer to main.dart](lib/main.dart)
```dart
class App extends StatelessWidget {
  const App({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //Register to isDarkMode
    return isDarkMode.whenRebuilderOr(
      onWaiting: () => const Center(
        child: const CircularProgressIndicator(),
      ),
      builder: () {
        return MaterialApp(
          //On app start, the state of isDarkMode is read from the storage
          theme: isDarkMode.state ? ThemeData.dark() : ThemeData.light(),
          home: .... 
        );
      },
    );
  }
}
```
To change the theme, we simply switch the state as follows:



[Refer to Extra Actions Button](lib/ui/pages/home_screen/extra_actions_button.dart#L24)
```dart
 isDarkMode.state = !isDarkMode.state;
```
## Localization setup

There are many ways to set up the localization of the app. In this example we first start by defining an abstract class I18N which have tree static methods and the default strings of our app.


[Refer to language_base file](lib/ui/common/localization/languages/language_base.dart)
```dart
abstract class I18N {
  ///A map of Locale to its I18N implementation
  static Map<Locale, I18N> _supportedLanguage = {
    Locale.fromSubtags(languageCode: 'en'): EN(), //EN and AR implements I18N
    Locale.fromSubtags(languageCode: 'ar'): AR(),
    //
    //Add new locales here
  };

  //Get the supportedLocale. To be used in MaterialApp widget
  static List<Locale>  getSupportedLocale => _supportedLanguage.keys.toList();
  
  //Get the translation from the chosen locale
  static I18N getLanguages(Locale locale) => _supportedLanguage[locale] ?? EN();

  //Default Strings
  String appTitle = 'States_rebuilder Example';
  String todos = 'Todos';

  String stats = 'Stats';

}
```
Now we have to define the EN and AR implementations of I18N interface:
 
[Refer to en_us.dart file](lib/ui/common/localization/languages/en_us.dart)
```dart
//This is the default language
class EN extends I18N {}
```

[Refer to ar.dart file](lib/ui/common/localization/languages/ar.dart)
```dart
//This is the default language
class AR extends I18N {
  String appTitle = 'States_rebuilder مثال';
  String todos = 'واجبات';

  String stats = 'إحصاء';



}
```

Now, we are ready to inject and persist our chosen locale.


[Refer to ar.dart file](lib/ui/common/localization/localization.dart)
```dart
//Inject and persist the locale
final locale = RM.inject<Locale>(
  () => Locale.fromSubtags(languageCode: 'en'),
  onData: (_) {
      //Each time the locale is changed, we refresh the i18n to get the write language implementation
    return i18n.refresh();
  },
  //Persist the locale
  persist: () => PersistState(
    key: '__localization__',
    //the stored String (json) represents the 
    //
    //take the stored String and return a Locale object
    fromJson: (String json) => Locale.fromSubtags(languageCode: json),
    //
    //any non supported locale will be stored as 'und'.
    //
    toJson: (locale) =>
        I18N.supportedLocale.contains(locale) ? locale.languageCode : 'und',
  ),
);
```

[Refer to ar.dart file](lib/ui/common/localization/localization.dart)
```dart
//Inject i18n
final Injected<I18N> i18n = RM.inject(
  () {
      //Whenever is refreshed, (from onData of locale) it gets the corresponding language implementation
    return I18N.getLanguages(locale.state);
  },
);
```

In the UI:

[Refer to main.dart file](lib/main.dart)
```dart
class App extends StatelessWidget {
  const App({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //Listen to the injected isDarkModel and locale
    return [isDarkMode, locale].whenRebuilderOr(
      onWaiting: () => const Center(
        child: const CircularProgressIndicator(),
      ),
      builder: () {
        return MaterialApp(
          //get the appTitle fom the state of i18n
          title: i18n.state.appTitle,
          //On app start, the locale is obtained from the storage.
          //If the languageCode is 'und' the return null to use the system language,
          //else return the obtained locale
          locale: locale.state.languageCode == 'und' ? null : locale.state,
          //Supported locales from the static method defined in I18N
          supportedLocales: I18N.supportedLocale(),
          //Use flutter defined delegates.
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: isDarkMode.state ? ThemeData.dark() : ThemeData.light(),
          home: ....
        );
      },
    );
  }
}
```
To change the locale, we can do it manually :

[Refer to main.dart file](lib/ui/pages/home_screen/languages.dart#L9)
```dart
locale.state = Locale.fromSubtags(languageCode: 'ar');
```

Or listen to the system's locale change, and mutate the locale state

[Refer to main.dart file](lib/main.dart#L21)
```dart
//
StateWithMixinBuilder.widgetsBindingObserver(
    //Called when the system locale is changed
    didChangeLocales: (context, locales) {
    if (locale.state.languageCode == 'und') {
        locale.state = locales.first;
    }
    },
    builder: (_, __) => App(),
),
```
## 
# ex_009_1_3_ca_todo_mvc_with_state_persistence

States_rebuilder is a simple and efficient state management solution for Flutter.
By this example, I will demonstrate the above statement.

The example consist of the [Todo MVC app](https://github.com/brianegan/flutter_architecture_samples/blob/master/app_spec.md) extended to handle dynamic dark/light theme and app internationalization.

# Setting persistance provider

Since we want to persist the chosen theme and language as well as the todos list, we start by defining the persistence provider.

with states_rebuilder, you have the freedom of choosing your storage provider. All you need to do is to implement the `IPersistStore` interface. 

## SharedPreferences:
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

## Hive:
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

## Sqflite:
It's not the best choice here, but I give it for demonstration purpose.
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

## Dynamic dark/lith theme
Since we want to toggle between dark and light mode, we inject and persist a Boolean value to know if we've chosen dark or light.

```dart
final isDarkMode = RM.inject<bool>(
  () => true,
  //Show our intention to persist the state by defining the persist parameter
  persist: () => PersistState(
    //Give it a unique key. [key / value]
    key: '__themeData__',
    //Tell how to transition from json to state and the opposite.
    //Our case is simple:
    //'1' is true, and '0' is false
    fromJson: (json) => json == '1',
    toJson: (themeData) => themeData ? '1' : '0',
  ),
);
```
That's all for the business logic part. In the UI, we can register to the injected `isDarkMode` and change its state.


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

<details>
  <summary>Click here to see how dynamic theming is tested</summary>

[Refer to main_test.dart file](test/main_test.dart#L9)
```dart
  testWidgets('Toggle theme should work', (tester) async {
    await tester.pumpWidget(App());
    //App start with dart model
    expect(Theme.of(RM.context).brightness == Brightness.dark, isTrue);

    //tap on the ExtraActionsButton
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    //And tap to toggle light mode
    await tester.tap(find.byKey(Key('__toggleDarkMode__')));
    await tester.pumpAndSettle();
    //
    //Expect the themeData is persisted
    expect(storage.store['__themeData__'], '0');
    //And theme is light
    expect(Theme.of(RM.context).brightness == Brightness.light, isTrue);
    //
    //Tap to toggle theme to dark mode
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleDarkMode__')));
    await tester.pumpAndSettle();
    //
    //The storage.stored themeData is updated
    expect(storage.store['__themeData__'], '1');
    //And theme is dark
    expect(Theme.of(RM.context).brightness == Brightness.dark, isTrue);
  });
```
</details>


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

<details>
  <summary>Click here to see how toggling the theme is tested</summary>

[Refer to main_test.dart file](test/main_test.dart#L39)
```dart
  testWidgets('Change language should work', (tester) async {
    await tester.pumpWidget(App());
    //App start with english
    expect(MaterialLocalizations.of(RM.context).alertDialogLabel, 'Alert');

    await tester.tap(find.byType(Languages));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AR'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pumpAndSettle();
    //ar is persisted
    expect(storage.store['__localization__'], 'ar');
    //App is in arabic
    expect(MaterialLocalizations.of(RM.context).alertDialogLabel, 'تنبيه');
    //
    await tester.tap(find.byType(Languages));
    await tester.pumpAndSettle();
    //tap to use system language
    await tester.tap(find.byKey(Key('__System_language__')));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pumpAndSettle();
    //und for systemLanguage is persisted
    expect(storage.store['__localization__'], 'und');
    //App is back to system language (english).
    expect(MaterialLocalizations.of(RM.context).alertDialogLabel, 'Alert');
  });
```
</details>


## Todos logic

For the todos we first start defining a Todo data class:


<details>
  <summary>Click here to see the Todo class</summary>

[Refer to todo.dart file](lib/domain/entities/todo.dart)
```dart
@immutable
class Todo {
  final String id;
  final bool complete;
  final String note;
  final String task;

  Todo(this.task, {String id, this.note, this.complete = false})
      : id = id ?? Uuid().v4();

  factory Todo.fromJson(Map<String, Object> map) {
    if (map == null) {
      return null;
    }
    return Todo(
      map['task'] as String,
      id: map['id'] as String,
      note: map['note'] as String,
      complete: map['complete'] as bool,
    );
  }

  // toJson is called just before persistance.
  Map<String, Object> toJson() {
    _validation();
    print('toJson');
    return {
      'complete': complete,
      'task': task,
      'note': note,
      'id': id,
    };
  }

  void _validation() {
    if (id == null) {
      // Custom defined error classes
      throw ValidationException('This todo has no ID!');
    }
    if (task == null || task.isEmpty) {
      throw ValidationException('Empty task are not allowed');
    }
  }

  Todo copyWith({
    String task,
    String note,
    bool complete,
    String id,
  }) {
    return Todo(
      task ?? this.task,
      id: id ?? this.id,
      note: note ?? this.note,
      complete: complete ?? this.complete,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Todo &&
        o.id == id &&
        o.complete == complete &&
        o.note == note &&
        o.task == task;
  }

  @override
  int get hashCode {
    return id.hashCode ^ complete.hashCode ^ note.hashCode ^ task.hashCode;
  }

  @override
  String toString() {
    return 'Todo(task:$task, complete: $complete)';
  }
}
```
</details>


The logic for adding, updating, deleting and toggling todos is encapsulated in ListTodoX extension.

[Refer to todo.dart file](lib/service/todos_state.dart)
```dart
extension ListTodoX on List<Todo> {
  //Add a todo
  List<Todo> addTodo(Todo todo) {
    return List<Todo>.from(this)..add(todo);
  }

  //Update todo
  List<Todo> updateTodo(Todo todo) {
    return map((t) => t.id == todo.id ? todo : t).toList();
  }

  List<Todo> deleteTodo(Todo todo) {
    return List<Todo>.from(this)..remove(todo);
  }

  List<Todo> toggleAll() {
    final allComplete = this.every((e) => e.complete);
    return map(
      (t) => t.copyWith(complete: !allComplete),
    ).toList();
  }

  List<Todo> clearCompleted() {
    return List<Todo>.from(this)
      ..removeWhere(
        (t) => t.complete,
      );
  }

  ///Parsing the state
  String toJson() => convert.json.encode(this);
  static List<Todo> fromJson(json) {
    final result = convert.json.decode(json) as List<dynamic>;
    return result.map((m) => Todo.fromJson(m)).toList();
  }
}
```

The next step is to inject and persist the todos list:

[Refer to injected.dart file](lib/injected.dart#L10)
```dart
final Injected<List<Todo>> todos = RM.inject(
  () => [],//Start with empty list
  persist: () => PersistState(
    key: '__Todos__',
    //parse the state
    toJson: (todos) => todos.toJson(),
    fromJson: (json) => ListTodoX.fromJson(json),
    onPersistError: (e, s) async {
      //If the persistence is failed, a snackbar is displayed and the state is undo to the last valid state
      ErrorHandler.showErrorSnackBar(e);
    },
  ),
  //As we want manually to undo the state after deleting a todo, we set the undo stack length to 1
  undoStackLength: 1,
);
```
As the todos can be filtered (All, completed, active), we inject a VisibilityFilter enumeration and a computed filtered todos:

[Refer to injected.dart file](lib/injected.dart#L25)
```dart
final activeFilter = RM.inject(() => VisibilityFilter.all);

//this todosFiltered will be recomputed whenever the activeFilter or todos state is changed.
final Injected<List<Todo>> todosFiltered = RM.injectComputed(
  compute: (_) {
    //Return the active todos
    if (activeFilter.state == VisibilityFilter.active) {
      return todos.state.where((t) => !t.complete).toList();
    }
    //Return the completed todos
    if (activeFilter.state == VisibilityFilter.completed) {
      return todos.state.where((t) => t.complete).toList();
    }
    //Return all todos
    return todos.state;
  },
);
```




## The UI

### AppTab
> The home contains two Tabs: [the List of Todos and Stats about the Todos](https://github.com/brianegan/flutter_architecture_samples/blob/master/app_spec.md#Home-Screen).

To Navigate between the list of todos and stats we define the AppTab enumeration and inject it.


[Refer to injected.dart file](lib/injected.dart#L40)
```dart
enum AppTab { todos, stats }

final activeTab = RM.inject(() => AppTab.todos);
```
In the home_screen we consume the activeTab injected model:

[Refer to home_screen.dart file](lib\ui\pages\home_screen\home_screen.dart#L33)
```dart

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ... ,
      body: todos.whenRebuilderOr(

        //Shows a loading screen until the Todos have been loaded from file storage or the web.
        onWaiting: () => const Center(
          child: const CircularProgressIndicator(),
        ),

        //subscribe to activeTab and depending on its state render the wanted widget
        builder: () => activeTab.rebuilder(
          () => activeTab.state == AppTab.todos
              ? const TodoList()
              : const StatsCounter(),
        ),
      ),
      floatingActionButton: ...,
      bottomNavigationBar: activeTab.rebuilder(
        () => BottomNavigationBar(
          currentIndex: AppTab.values.indexOf(activeTab.state),
          onTap: (index) {
            //Mutate the state of the activeTab
            activeTab.state = AppTab.values[index];
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text(i18n.state.stats),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              title: Text(i18n.state.todos),
            ),
          ],
        ),
      ),
    );
  }
```

### Load and display list of todos
> [Displays the list of Todos entered by the User](https://github.com/brianegan/flutter_architecture_samples/blob/master/app_spec.md#List-of-Todos)

On app start, the list of todos is fetched from the provided storage. Once the list of todos is obtained, we use a listView builder to display to todos items.

For performance and build optimization raisons, we will not pass any dynamic parameter to the `TodoItem` so that we can use the `const` modifier.

To get the state of any todo from its `TodoItem` child widgets we will relay on `InheritedWidget`.

With states_rebuilder, we can inject widget-aware state; that is, the state is obtained depending on its position in the widget tree. Here we will use the concept of InheritedWidget.

To do so we first define a global inject to represent the state of an Item.

Note: I assume you are familiar on How InheritedWidget works. [Read here for more information](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)


[Refer to injected.dart file](lib\injected.dart#L52)
```dart
//This is called the global state reference of Injected<Todo> 
final Injected<Todo> injectedTodo = RM.inject(() => null);
```
To injected an Injected<Todo> in the widget tree we use :

```dart
  //Widget-aware injection
  return injectedTodo.inherited(
    state: () =>  todos[index],// the Todo state
    builder: (_) => const TodoItem(),
  );
```

Form a child widget we can get the injected Todo:

```dart
  final injectedTodo = injectedTodo(context); //Internally call .of(context) of InheritedWidget
```


```dart
class TodoList extends StatelessWidget {
  const TodoList();
  @override
  Widget build(BuildContext context) {

    //Subscribe to todosFiltered. 
    //todosFiltered.rebuilder is invoked each time the todos and/or activeFilter injected models are changed
    return todosFiltered.rebuilder(
      () {
        final todos = todosFiltered.state;
        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (BuildContext context, int index) {
            
            //
            return injectedTodo.inherited(
              key: Key('${todos[index].id}'),
              state: () =>  todos[index],
              //Build is optimized by using const
              builder: (_) => const TodoItem(),
              connectWithGlobal: true,
            );
          },
        );
      },
      shouldRebuild: () => todosFiltered.hasData || todosFiltered.hasError,
    );
  }
}
```




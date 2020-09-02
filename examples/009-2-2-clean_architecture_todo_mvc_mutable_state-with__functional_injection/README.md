# clean_architecture_todo_mvc_cloud_firestore_mutable_state

> Don't forget to run `flutter create .` in the terminal in the project directory to create platform-specific files.

>In this example we will use global functional injection


<img align="right" src="https://github.com/brianegan/flutter_architecture_samples/blob/master/assets/todo-list.png" alt="List of Todos Screen">

This is an implementation of TodoMVC for Flutter from the [flutter Architecture samples](https://github.com/brianegan/flutter_architecture_samples) repository.
In the repository you find the same app implemented using different architectural concepts and tools, and states_rebuilder is one of them.

Here I will go through the detailed implementation, using states_rebuilder adding the following feature:
* I will use sharedPreference for persistance;
* I will make the app more user friendly in the sense, if the user adds, updates, deletes a todo, the UI is instantly updated and an async request is sent to firebase to perform the action. IF the updating firebase fails, the app returns to the old state and displays a SnackBar informing the user about the error.

in this example, I will use mutable state. you can find the same app implemented with immutable state [here](../009-clean_architecture_todo_mvc_cloud_firestore_immutable_state)

* [**Todo MVC with immutable state and firebase cloud service**](../009-1-1-clean_architecture_todo_mvc_cloud_firestore_immutable_state_with_injector).
* [**Todo MVC with immutable state and firebase cloud service (Using global functional injection)**](../009-1-2-clean_architecture_todo_mvc_cloud_firestore_immutable_state_with_functional_injection) 
* [**Todo MVC with mutable state and sharedPreferences for persistence**](../009-2-1-clean_architecture_todo_mvc_mutable_state_with_injector)
* [**Todo MVC following flutter_bloc library approach**](../009-todo_mvc_the_flutter_bloc_way) 
* [**Todo MVC following flutter_bloc library approach (Using global functional injection)**](../09-3-2-todo_mvc_the_flutter_bloc_way_with__functional_injection)



This is how I will architect the app: 

![Clean Architecture](https://github.com/GIfatahTH/repo_images/blob/master/008-Clean-Architecture.png).

The architecture consists of something like onion layers, the innermost one is the domain layer, the middle layer is the service layer and the outer layer consists of three parts: the user interface  UI, data_source, and infrastructure. Each of the parts of the architecture is implemented using folders.


Code dependencies can only point inwards. Nothing in an inner circle can know anything at all about something in an outer circle. In particular, the name of something declared in an outer circle must not be mentioned by the code in the inner circle. In particular, data_source and infrastructure must implement interfaces defined in the service layer.

For more detail on the implemented clean architecture read [this article](https://medium.com/flutter-community/clean-architecture-with-states-rebuilder-has-never-been-cleaner-6c9b91c3b9b6#a588)

* [Domain](#Domain-layer)
    * [Entities](##Entities)
        * [Todo entity](###Todo-entity)

* [Service layer](#Service-layer)
    * [interfaces](##interface)
        * [ITodosRepository](###ITodosRepository)
    * [Exceptions](##Exceptions)
        * [PersistanceException](###PersistanceException)
    * [Common (Utils/ Helpers)](##Common-(Utils-/-Helpers))
    * [TodosService](##TodosService)
* [data_source](#data_source)
  * [TodosRepository](##TodosRepository)
* [UI (User Interface)](#UI-(User-Interface))
  * [injected.dart](##injected.dart)
  * [main.dart](##main.dart)
  * [app.dart](##app.dart)
  * [pages](##pages)
    * [Auth page](###Auth-page)
    * [Home pages](###HomeScreen)
    * [Detail page](###Detail-page)
    * [add edit page](###add-edit-page)


Staring from the most independent part,  the innermost domain layer.
# Domain layer
## Entities

### User entity

### Todo entity
**file:lib/domain/entities/todo.dart**
```dart

@immutable
class Todo {
  final String id;
  final bool complete;
  final String note;
  final String task;

  Todo(this.task, {String id, this.note, this.complete = false})
      : id = id ?? flutter_arch_sample_app.Uuid().generateV4();

  factory Todo.fromJson(Map<String, Object> map) {
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
    return 'Todo(id: $id,task:$task, complete: $complete)';
  }
}
```

## Common

# Service layer
## interface
The service layer can directly depend  on te the domain layer and inversely depend on the data_source outer layer. data_source implements the abstract classes defined inside the folder

### ITodosRepository
**lib\service\interfaces\i_todo_repository.dart**
```dart
abstract class ITodosRepository {
  /// Loads todos
  Future<List<Todo>> loadTodos();
  // Persists todos to local disk and the web
  Future saveTodos(List<Todo> todos);
}
```
## Exceptions
Exceptions and errors thrown from the data_source must be translated to Exceptions recognized by the service layer.
In the Exceptions folder we define the Exceptions classes as expected from the service layer, any other Exceptions will be thrown to break the app.
### PersistanceException
**lib\service\exceptions\persistance_exception.dart**
```dart
class PersistanceException extends Error {
  final String message;
  PersistanceException(this.message);
  @override
  String toString() {
    return message.toString();
  }
}
```

## Common (Utils / Helpers)
**lib\service\common\enums.dart**
```dart
enum VisibilityFilter { all, active, completed }
```


## TodosService

```dart

class TodosService {
  //Constructor injection of the ITodoRepository abstract class.
  TodosService(ITodosRepository todoRepository)
      : _todoRepository = todoRepository;

  //private fields
  final ITodosRepository _todoRepository;
  List<Todo> _todos = const [];

  //public field
  VisibilityFilter activeFilter = VisibilityFilter.all;

  //getters
  List<Todo> get todos {
    if (activeFilter == VisibilityFilter.active) {
      return [..._activeTodos];
    }
    if (activeFilter == VisibilityFilter.completed) {
      return [..._completedTodos];
    }
    return [..._todos];
  }

  List<Todo> get _completedTodos => _todos.where((t) => t.complete).toList();
  List<Todo> get _activeTodos => _todos.where((t) => !t.complete).toList();
  int get numCompleted => _completedTodos.length;
  int get numActive => _activeTodos.length;
  bool get allComplete => _activeTodos.isEmpty;

  //methods for CRUD
  Future<void> loadTodos() async {
    // await Future.delayed(Duration(seconds: 5));
    // throw PersistanceException('net work error');
    return _todos = await _todoRepository.loadTodos();
  }

  Stream<void> addTodo(Todo todo) async* {
    _todos.add(todo);
    yield null;
    try {
      await _todoRepository.saveTodos(_todos);
    } catch (error) {
      _todos.remove(todo);
      yield null;
      throw error;
    }
  }

  //on updating todos, states_rebuilder will instantly update the UI,
  //Meanwhile the asynchronous method saveTodos is executed in the background.
  //If an error occurs, the old state is returned and states_rebuilder update the UI
  //to display the old state and shows a snackBar informing the user of the error.

  Stream<void> updateTodo(Todo todo) async* {
    final oldTodo = _todos.firstWhere((t) => t.id == todo.id);
    final index = _todos.indexOf(oldTodo);
    _todos[index] = todo;
    yield null;
    //here states_rebuild will update the UI to display the new todos
    try {
      await _todoRepository.saveTodos(_todos);
    } catch (error) {
      //on error return to the initial state
      _todos[index] = oldTodo;
      yield null;
      //for states_rebuild to be informed of the error, we rethrow the error
      throw error;
    }
  }

  Stream<void> deleteTodo(Todo todo) async* {
    final todoToDelete = _todos.firstWhere((t) => t.id == todo.id);
    final index = _todos.indexOf(todoToDelete);
    _todos.removeAt(index);
    yield null;
    try {
      await _todoRepository.saveTodos(_todos);
    } catch (error) {
      //on error reinsert the deleted todo
      _todos.insert(index, todo);
      yield null;
      throw error;
    }
  }

  Stream<void> toggleAll() async* {
    final allComplete = _todos.every((todo) => todo.complete);
    var beforeTodos = <Todo>[];

    for (var i = 0; i < _todos.length; i++) {
      beforeTodos.add(_todos[i]);
      _todos[i] = _todos[i].copyWith(complete: !allComplete);
    }

    yield null;
    try {
      await _todoRepository.saveTodos(_todos);
    } catch (error) {
      //on error return to the initial state
      _todos = beforeTodos;
      yield null;
      throw error;
    }
  }

  Stream<void> clearCompleted() async* {
    var beforeTodos = List<Todo>.from(_todos);
    _todos.removeWhere((todo) => todo.complete);
    yield null;
    try {
      await _todoRepository.saveTodos(_todos);
    } catch (error) {
      //on error return to the initial state
      _todos = beforeTodos;
      yield null;
      throw error;
    }
  }
}
```
# data_source
We will use sharedPreference to save todos locally.

Our app is independent of the detailed implementation of the data_source provided that it conforms to the interfaces defined in the service layer.

See [flutter Architecture samples](https://github.com/brianegan/flutter_architecture_samples)  for another implementation.

## TodosRepository
`TodosRepository` implements `ITodoRepository` which have two methods: one for fetching todos (loadTodos) and the other for saving todos (saveTodos). 

**lib\data_source\todo_repository.dart**
```dart

class TodosRepository implements ITodosRepository {
  final SharedPreferences prefs;

  TodosRepository({this.prefs});
  @override
  Future<List<Todo>> loadTodos() async {
    try {
      final result = prefs.getString('todos');
      if (result == null) {
        return [];
      }
      List<dynamic> todosList = json.decode(result);
      return todosList.map((t) => Todo.fromJson(t)).toList();
    } catch (e) {
      throw PersistanceException('There is a problem in loading todos : $e');
    }
  }

  @override
  Future saveTodos(List<Todo> todos) async {
    try {
      final t = todos.map((e) => e.toJson()).toList();

      await prefs.setString('todos', json.encode(t));
    } catch (e) {
      throw PersistanceException(
          'There is a problem in saving todos :${e?.message}');
    }
  }
}
```

# UI (User Interface)

## main.dart
[**lib\main.dart**](lib\main.dart)

## injected.dart
[**lib\injected.dart**](lib\injected.dart)

 ```dart
 //Note that order is not mandatory because models are injected lazily.


 //Inject SharedPreferences
 final sharedPreferences = RM.injectFuture<SharedPreferences>(
  () async {
    return SharedPreferences.getInstance();
  },
);

//Inject TodosRepository via its interface ITodosRepository
//this give us the ability to mock the TodosRepository in test.
final todosRepository = RM.injectFuture<ITodosRepository>(
  () async {
    //await until the SharedPreferences is initialized to create an instance
    //of TodosRepository
    return TodosRepository(
      prefs: await sharedPreferences.stateAsync,
    );
  },
  onError: (e, s) => print(e),
);

final todosService = RM.injectFuture<TodosService>(
  () async {
    //await until the TodosRepository is initialized to create an instance
    //of TodosService
    return TodosService(
      await todosRepository.stateAsync,
    );
  },
  //If the TodosService throws, error will be captured and treated here
  onError: (e, s) {
    //This is the default error handling. it can be override with setState.
    ErrorHandler.showErrorDialog(RM.context, e);
  },
);

//This will optimized the rebuild so that the filteredTodos will
//be recalculated only when the list of todos changes.
final filteredTodos = RM.injectComputed(
  compute: (_) => todosService.state.todos,
);

final appTab = RM.inject(() => AppTab.todos);

 ```
## app.dart
**lib\app.dart**
```dart
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
```

## pages
states_rebuilder is based on the concept of fo ReactiveModels. ReactiveModels can be local or global.

### Auth page
* [**auth_page.dart**](lib\ui\pages\auth_page\auth_page.dart)

### Home page
* [**home_screen.dart**](lib\ui\pages\home_screen\home_screen.dart)
* [**todo_list.dart**](lib\ui\pages\home_screen\todo_list.dart)
* [**todo_item.dart**](lib\ui\pages\home_screen\todo_item.dart)
* [**filter_button.dart**](lib\ui\pages\home_screen\filter_button.dart.dart)
* [**extra_actions_button.dart**](lib\ui\pages\home_screen\extra_actions_button.dart)
* [**stats_counter.dart**](lib\ui\pages\home_screen\stats_counter.dart)
### Detail page
* [**detail_screen**](lib\ui\pages\detail_screen\detail_screen.dart)
### add edit page
* [**add_edit_screen**](lib\ui\pages\add_edit_screen.dart\add_edit_screen.dart)

# Test 
The logic and the UI are tested (see the test folder).
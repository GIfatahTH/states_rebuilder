# clean_architecture_todo_mvc_cloud_firestore_mutable_state


<img align="right" src="https://github.com/brianegan/flutter_architecture_samples/blob/master/assets/todo-list.png" alt="List of Todos Screen">

This is an implementation of TodoMVC for Flutter from the [flutter Architecture samples](https://github.com/brianegan/flutter_architecture_samples) repository.
In the repository you find the same app implemented using different architectural concepts and tools, and states_rebuilder is one of them.

Here I will go through the detailed implementation, using states_rebuilder adding the following feature:
* I will use sharedPreference for persistance;
* I will make the app more user friendly in the sense, if the user adds, updates, deletes a todo, the UI is instantly updated and an async request is sent to firebase to perform the action. IF the updating firebase fails, the app returns to the old state and displays a SnackBar informing the user about the error.

in this example, I will use mutable state. you can find the same app implemented with immutable state [here](../009-clean_architecture_todo_mvc_cloud_firestore_immutable_state)

This is how I will architect the app: 

![Clean Architecture](https://github.com/GIfatahTH/repo_images/blob/master/008-Clean-Architecture.png).

The architecture consists of something like onion layers, the innermost one is the domain layer, the middle layer is the service layer and the outer layer consists of three parts: the user interface  UI, data_source, and infrastructure. Each of the parts of the architecture is implemented using folders.


Code dependencies can only point inwards. Nothing in an inner circle can know anything at all about something in an outer circle. In particular, the name of something declared in an outer circle must not be mentioned by the code in the inner circle. In particular, data_source and infrastructure must implement interfaces defined in the service layer.

For more detail on the implemented clean architecture read [this article](https://medium.com/flutter-community/clean-architecture-with-states-rebuilder-has-never-been-cleaner-6c9b91c3b9b6#a588)

* [Domain](#Domain-layer)
    * [Entities](##Entities)
        * [User entity](###User-entity)
        * [Todo entity](###Todo-entity)
    * [Value objects](##value_object)
        * [Email](###Email)
        * [Password](###Password)
    * [exceptions](##exceptions)
        * [ValidationException](###ValidationException)
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
**file:lib/domain/entities/user.dart**

```dart
@immutable
class User {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  User({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  User copyWith({
    String uid,
    String email,
    String displayName,
    String photoUrl,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return User(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  static User fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is User &&
        o.uid == uid &&
        o.email == email &&
        o.displayName == displayName &&
        o.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode;
  }
}
```

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

## value_object

### Email
**file:lib/domain/value_object/email.dart**
```dart
class Email {
  final String value;

  Email(this.value) {
    validate(value);
  }

  static void validate(String password) {
    if (!_emailRegExp.hasMatch(password)) {
      //On the constriction, if the email is not valid, ValidationException is thrown.
      //states_rebuilder catches the exception, and the Email ReactiveModel state to has error
      //and notify observer widgets
      throw ValidationException('Enter a valid password');
    }
  }
  //email validation
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
}
```

### Password
**file:lib/domain/value_object/password.dart**
```dart
class Password {
  final String value;
  Password(this.value) {
    validate(value);
  }

  static void validate(String password) {
    if (!_passwordRegExp.hasMatch(password)) {
      throw ValidationException('Enter a valid password');
    }
  }
  //Password validation logic
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );
}
```

## Common
### exceptions

### ValidationException
**lib\domain\exceptions\validation_exception.dart**
```dart
class ValidationException extends Error {
  final String message;

  ValidationException(this.message);
  @override
  String toString() {
    return message;
  }
}
```
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
  //
  List<Todo> _todos = const [];

  //public field
  VisibilityFilter activeFilter = VisibilityFilter.all;

  //getters
  List<Todo> get todos {
    if (activeFilter == VisibilityFilter.active) {
      return _activeTodos;
    }
    if (activeFilter == VisibilityFilter.completed) {
      return _completedTodos;
    }
    return _todos;
  }

  List<Todo> get _completedTodos => _todos.where((t) => t.complete).toList();
  List<Todo> get _activeTodos => _todos.where((t) => !t.complete).toList();
  int get numCompleted => _completedTodos.length;
  int get numActive => _activeTodos.length;
  bool get allComplete => _activeTodos.isEmpty;

  //methods for CRUD
  Future<void> loadTodos() async {
    return _todos = await _todoRepository.loadTodos();
  }

  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    await _todoRepository.saveTodos(_todos).catchError((error) {
      _todos.remove(todo);
      throw error;
    });
  }

  //on updating todos, states_rebuilder will instantly update the UI,
  //Meanwhile the asynchronous method saveTodos is executed in the background.
  //If an error occurs, the old state is returned and states_rebuilder update the UI
  //to display the old state and shows a snackBar informing the user of the error.

  Future<void> updateTodo(Todo todo) async {
    final oldTodo = _todos.firstWhere((t) => t.id == todo.id);
    final index = _todos.indexOf(oldTodo);
    _todos[index] = todo;
    //here states_rebuild will update the UI to display the new todos
    await _todoRepository.saveTodos(_todos).catchError((error) {
      //on error return to the initial state
      _todos[index] = oldTodo;
      //for states_rebuild to be informed of the error, we rethrow the error
      throw error;
    });
  }

  Future<void> deleteTodo(Todo todo) async {
    final todoToDelete = _todos.firstWhere((t) => t.id == todo.id);
    final index = _todos.indexOf(todoToDelete);
    _todos.removeAt(index);
    return _todoRepository.saveTodos(_todos).catchError((error) {
      //on error reinsert the deleted todo
      _todos.insert(index, todo);
      throw error;
    });
  }

  Future<void> toggleAll() async {
    final allComplete = _todos.every((todo) => todo.complete);
    var beforeTodos = <Todo>[];

    for (var i = 0; i < _todos.length; i++) {
      beforeTodos.add(_todos[i]);
      _todos[i] = _todos[i].copyWith(complete: !allComplete);
    }
    return _todoRepository.saveTodos(_todos).catchError(
      (error) {
        //on error return to the initial state
        _todos = beforeTodos;
        throw error;
      },
    );
  }

  Future<void> clearCompleted() async {
    var beforeTodos = List<Todo>.from(_todos);
    _todos.removeWhere((todo) => todo.complete);
    await _todoRepository.saveTodos(_todos).catchError(
      (error) {
        //on error return to the initial state
        _todos = beforeTodos;
        throw error;
      },
    );
  }
}
```
# data_source
We will use sharedPreference to save todos locally.

Our app is independent of the detailed implementation of the data_source provided that it conforms to the interfaces defined in the service layer.

See [flutter Architecture samples](https://github.com/brianegan/flutter_architecture_samples)  for another implementation.

## AuthRepository
**lib\data_source\auth_repository.dart**
```dart
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User> currentUser() async {
    final FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    return _fromFireBaseUserToUser(firebaseUser);
  }

  @override
  Future<User> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      AuthResult authResult =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        //throw exception defined in the service layer
        throw PersistanceException(e.message);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final AuthResult authResult =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw PersistanceException(e.message);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  _fromFireBaseUserToUser(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }
```
## TodosRepository
`TodosRepository` implements `ITodoRepository` which have two methods: one for fetching todos (loadTodos) and the other for saving todos (saveTodos). 

**lib\data_source\todo_repository.dart**
```dart
class TodosRepository implements ITodosRepository {
  //The implementation of ITodoRepository interface in a detail, you can find more efficient implementation than the one I used
  final databaseReference = Firestore.instance;
  final User user;
  //receive the actual user in the constructor
  TodosRepository({@required this.user});
  //The path of the collection
  //We remove '/' from the user id, because '/' is used by firestore to determine the path.
   String get collectionPath {
    return 'todos/byUser/${user.uid.replaceAll('/', '')}';
  }

  @override
  Future<List<Todo>> loadTodos() async {
    try {
      final snapshot =
          await databaseReference.collection(collectionPath).getDocuments();

      var todos = <Todo>[];

      snapshot.documents.forEach(
        (f) {
          todos.add(Todo.fromJson(f.data));
        },
      );
      //save the list of todos in local variable. It will be used for optimization.
      _cashedTodos = List<Todo>.from(todos);
      return todos;
    } catch (e) {
      throw PersistanceException('There is a problem in loading todos : $e');
    }
  }

  //The cashed list of todos
  List<Todo> _cashedTodos = [];

  //the saveTodos receives the whole updated list of todos.
  //We can update all the collection in the firestore.
  //But we want to be more optimized by saving only the todo that has changed (add, deleted, updated) not all the list of todos.
  //, For this reason, we used the _cashedTodos local variable.
  @override
  Future saveTodos(List<Todo> todos) async {

    try {
      final List<Todo> newTodos = List<Todo>.from(todos);
      //compare the old with new todos to determine what to add, delete, or update
      for (Todo oldTodo in _cashedTodos) {
        final newTodo =
            newTodos.firstWhere((t) => t.id == oldTodo.id, orElse: () => null);
        if (newTodo != null) {
          if (oldTodo == newTodo) {
          //remove the newTodo from the list of new todos
          //the new todos list contains an old todo
            newTodos.remove(newTodo);
          }
        } else {
          //the new todos does not contain an old todo
          //It must be deleted

          //remove '/' from provided id ('/ 'is used for path).
          final documentId = oldTodo.id.replaceAll('/', '');
          await databaseReference
              .collection(collectionPath)
              .document('$documentId')
              .delete();
        }
      }

      //All the old todos are removed from the new todos list
      //what remains is new todos added by the user
      for (Todo newTodo in newTodos) {
        //create new todo in the firestore
        final documentId = newTodo.id.replaceAll('/', '');
        await databaseReference
            .collection(collectionPath)
            .document('$documentId')
            .setData(newTodo.toJson());
      }
      _cashedTodos = List<Todo>.from(todos);
    } catch (e) {
      throw PersistanceException(
          'There is a problem in saving todos :${e?.message}');
    }
  }
}
```

# UI (User Interface)

In the UI part we will do four things:
* Injection of `AuthState` and `TodosState` using `Injector` widget. From the injected instances we can get the global ReactiveModel of the injected instances using `RM.get<T>()`.
  ```dart
  final authStateRM = RM.get<AuthState>();
  final todosStateRM = RM.get<TodosState>();
  ```
* Create local ReactiveModel models to handle UI state of `TabBar` and `PopupMenuButton`
  ```dart
    RM.create(AppTab.todos);
    RM.create(VisibilityFilter.all);
  ```
  Local ReactiveModel are often used with ReactiveModel keys.
* subscribe to a one or more ReactiveModels using one of the four observer widgets `StateBuilder`, `WhenRebuilder`, `WhenRebuilderOr`, or `OnSetStateListener`
* state mutation and notification sending
  for immutable state we use : 
    * Sync mutation using the `value` getter and setter:
      ```dart
        _activeTabRM.value = AppTab.values[index];
      ```
    * Sync mutation using `setValue` method:
      ```dart
        activeFilterRM.setValue(
                () => filter,
                onData: (context, data) {

                },
                onError : (context, error){

                }
              );
      ```
    * Async mutation using `future` method
      ```dart
        observe: () => RM.get<AuthState>()
            ..future(
              (authState) => AuthState.currentUser(authState),
            )
            .onError(ErrorHandler.showErrorDialog),
      ```
    * Async mutation using `stream` method
      ```dart
        todosStateRM
                .stream((t) => TodosState.addTodo(t, todo))
                .onError(ErrorHandler.showErrorSnackBar);
      ```

## main.dart
[**lib\main.dart**](lib\main.dart)

## app.dart
**lib\app.dart**
```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //Injecting TodosState
        Inject(
          () => TodosState(
            todos: [],//initial empty todos
            activeFilter: VisibilityFilter.all,
            todoRepository: TodosRepository(
              //get the user from the injected AuthState
              user: IN.get<AuthState>().user,
            ),
          ),
        )
      ],
      //whenever the AuthState ReactiveModel emits a notification the TodosState injected above
      //will be refreshed to get the nex user. 
      reinjectOn: [RM.get<AuthState>()],
      builder: (_) => MaterialApp(
        title: StatesRebuilderLocalizations().appTitle,
        theme: ArchSampleTheme.theme,
        localizationsDelegates: [
          ArchSampleLocalizationsDelegate(),
          StatesRebuilderLocalizationsDelegate(),
        ],
        home: StateBuilder<AuthState>(
          //Key to be displayed in the consol when RM.debugWidgetsRebuild is true
          key: Key('Current user'),
          //Never update unless user is changed
          watch: (rm) => rm.value.user,
          //get the injected AuthState and invoke the currentUser method,
          //using the future method.
          //The future method callBack exposes the current state 
          observe: () => RM.get<AuthState>()
            ..future(
              (authState) => AuthState.currentUser(authState),
            )
          //When user changes, AuthState ReactiveModel will notify this StateBuilder.
          //if the new state is InitAuthState then we will go to AuthScreen,
          //If it is not, that means a user is singed in and we will go to the HomeScreen
          builder: (context, authStateRM) =>
              authStateRM.value is InitAuthState ? AuthScreen() : HomeScreen(),
        ),
        routes: {
          ArchSampleRoutes.addTodo: (context) => AddEditPage(),
        },
      ),
    );
  }
}
```
Two notes here:
* reinjectOn : The injected instance of TodosState depends on the authenticated user. By using `reinjectOn: [RM.get<AuthState>()],` we told states_rebuilder to refresh the todosState registered instance each time the RM.get<AuthState>() emits a notification.

* Global vs Local ReactiveModel: Injected ReactiveModels have global access, that is any widget cas access their state. Also ReactiveModel can local that is created, listen to, and notify state within a widget.
```dart
observe: () => RM.get<AuthState>()
            ..future(
              (authState) => AuthState.currentUser(authState),
            )
            .onError(ErrorHandler.showErrorDialog),
```
In this code we get the global `AuthState` ReactiveModel, and subscribe to it using `StateBuilder` widget. This StateBuilder widget can be notified to rebuild from the `AuthScreen` and the `HomeScreen` pages.

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
# clean_architecture_todo_mvc_cloud_firestore_immutable_state

>In this example we will use functional injection

<img align="right" src="https://github.com/brianegan/flutter_architecture_samples/blob/master/assets/todo-list.png" alt="List of Todos Screen">

This is an implementation of TodoMVC for Flutter from the [flutter Architecture samples](https://github.com/brianegan/flutter_architecture_samples) repository.
In the repository you find the same app implemented using different architectural concepts and tools, and states_rebuilder is one of them.

Here I will go through the detailed implementation, using states_rebuilder adding the following feature:
* For the backend, I will use Firebase cloud;
* I will use Firebase auth service to allow users to sing up / sign in and see their proper todos.
* I will make the app more user friendly in the sense, if the user adds, updates, deletes a todo, the UI is instantly updated and an async request is sent to firebase to perform the action. IF the updating firebase fails, the app returns to the old state and displays a SnackBar informing the user about the error.

in this example, I will use immutable state. you can find the same app implemented with mutable state [here](../009-clean_architecture_todo_mvc_mutable_state)

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
        * [IAuthRepository](###IAuthRepository)
        * [ITodosRepository](###ITodosRepository)
    * [Exceptions](##Exceptions)
        * [PersistanceException](###PersistanceException)
    * [Common (Utils/ Helpers)](##Common-(Utils-/-Helpers))
    * [AuthState](##AuthState)
    * [TodosState](##TodosState)
* [data_source](#data_source)
  * [AuthRepository](##AuthRepository)
  * [TodosRepository](##TodosRepository)
* [UI (User Interface)](#UI-(User-Interface))
  * [injected.dart](##injected.dart)
  * [main.dart](##main.dart)
  * [app.dart](##app.dart)
  * [pages](##pages)
    * [Auth page](###Auth-page)
    * [Home pages](###HomeScreen)
    * [Detail page](###Detail-page)
    * [add edit page](###add-edit-page)²


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

### IAuthRepository
**lib\service\interfaces\i_auth_repository.dart**
```dart
abstract class IAuthRepository {
  Future<User> currentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}
```

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

## AuthState
In the AuthState we hold the state of the authentication.
**lib\service\auth_state.dart**
```dart
//It is immutable
@immutable
class AuthState {
  //We need the IAuthRepository which will be injected through the constructor
  final IAuthRepository _authRepository;
  // the current user
  final User user;
  AuthState({
    @required IAuthRepository authRepository,
    @required this.user,
  }) : _authRepository = authRepository;

  //get the current user
  Future<AuthState> currentUser() async {
      //TODO
  }
  
  //create a user from email and password
  Future<AuthState> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
      //TODO
  }
   
  //sign in with email and password
  Future<AuthState> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
      //TODO
  }
  
  //sign out
   Future<AuthState> signOut() async {
       //TODO
   }
  

  AuthState copyWith({
    IAuthRepository authRepository,
    User user,
  }) {
    return AuthState(
      authRepository: authRepository ?? _authRepository,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AuthState && o.user == user;
  }

  @override
  int get hashCode => user.hashCode;
  @override
  String toString() => 'AuthState(user: $user)';
}
```
`AuthState` is immutable. It accepts in the constructor, the auth repository and the user instance.

Methods in `AuthState` must return a new instance of the `AuthState`. The role of a method here is to determine the next `AuthState` starting from the current `AuthState`.

Let's start implementing the `currentUser` method :

```dart
  Future<AuthState> currentUser() async {
    // fetch current user from the authRepository
    final User currentUser = await _authRepository.currentUser();
    //once the currentUse is obtained, return an new copy from AuthState with the new user.
    return copyWith(
      user: currentUser,
    );
  }
```

As you can see what currentUse method does is from the current state of AuthState state, it returns a new state of the AuthState.

As it is the case, and form more performance gain, it is more connivent to make the currentUser a static method.

```dart
  static Future<AuthState> currentUser(AuthState authState) async {
    final User currentUser = await authState._authRepository.currentUser();
    return authState.copyWith(
      user: currentUser,
    );
  }
```
It is a simple static pure function method, it gets the current state as input and returns the next state as output.

We may want to check if the obtained current user is null and return a particular state that we can name the initial state:

```dart
static Future<AuthState> currentUser(AuthState authState) async {
    final User currentUser = await authState._authRepository.currentUser();
    if (currentUser != null) {
        //if currentUser is not null, we return a new state of AuthState
      return authState.copyWith(
        user: currentUser,
      );
    }
    //if currentUse is null we return a special state that we defined to be the InitAuthState
    return InitAuthState(authState._authRepository);
  }
```
The InitAuthState must extends the AuthState and provide initial parameter:

```dart
class InitAuthState extends AuthState {
  //receives the authRepository in the constructor
  InitAuthState(IAuthRepository authRepository)
      : super(
          authRepository: authRepository,
          //user is null, It can have other values
          user: null,
        );
}
```
In the UI, we will use this InitAuthState to display the AuthScreen or the HomeScreen

```dart 
 //see later
 authStateRM.value is InitAuthState ? AuthScreen() : HomeScreen(),
```

The other methods implements are not difficult than currentUse methods implement:

```dart
  static Future<AuthState> createUserWithEmailAndPassword(
    AuthState authState,
    String email,
    String password,
  ) async {
    final user = await authState._authRepository.createUserWithEmailAndPassword(
      email,
      password,
    );
    return authState.copyWith(user: user);
  }

  static Future<AuthState> signInWithEmailAndPassword(
    AuthState authState,
    String email,
    String password,
  ) async {
    final user = await authState._authRepository.signInWithEmailAndPassword(
      email,
      password,
    );
    return authState.copyWith(user: user);
  }

  static Future<AuthState> signOut(AuthState authState) async {
    await authState._authRepository.signOut();
    return InitAuthState(authState._authRepository);
  }
```

As you can see AuthState is a pure dart class, with pure function, easily tested methods. (see test folder)

## TodosState

```dart
@immutable
class TodosState {
  //Constructor injection of the ITodoRepository abstract class,
  TodosState({
    ITodosRepository todoRepository,
    List<Todo> todos,
    VisibilityFilter activeFilter,
  })  : _todoRepository = todoRepository,
        _todos = todos,
        _activeFilter = activeFilter;

  //private fields
  final ITodosRepository _todoRepository;
  final List<Todo> _todos;
  final VisibilityFilter _activeFilter;

  //public getters
  List<Todo> get todos {
    if (_activeFilter == VisibilityFilter.active) {
      return _activeTodos;
    }
    if (_activeFilter == VisibilityFilter.completed) {
      return _completedTodos;
    }
    return _todos;
  }

  int get numCompleted => _completedTodos.length;
  int get numActive => _activeTodos.length;
  bool get allComplete => _activeTodos.isEmpty;
  //private getter
  List<Todo> get _completedTodos => _todos.where((t) => t.complete).toList();
  List<Todo> get _activeTodos => _todos.where((t) => !t.complete).toList();

  //methods for CRUD
  static Future<TodosState> loadTodos(TodosState todosState) async {
     //TODO
  }

  static Stream<TodosState> addTodo(TodosState todosState, Todo todo) async* {
    //TODO
  }

  static Stream<TodosState> updateTodo(
      TodosState todosState, Todo todo) async* {
   //TODO
  }

  static Stream<TodosState> deleteTodo(
      TodosState todosState, Todo todo) async* {
    //TODO
  }

  static Stream<TodosState> toggleAll(TodosState todosState) async* {
    //TODO
  }

  static Stream<TodosState> clearCompleted(TodosState todosState) async* {
    //TODO
  }

  TodosState copyWith({
    ITodosRepository todoRepository,
    List<Todo> todos,
    VisibilityFilter activeFilter,
  }) {
    final filter = todos?.isEmpty == true ? VisibilityFilter.all : activeFilter;
    return TodosState(
      todoRepository: todoRepository ?? _todoRepository,
      todos: todos ?? _todos,
      activeFilter: filter ?? _activeFilter,
    );
  }

  @override
  String toString() =>
      'TodosState(_todoRepository: $_todoRepository, _todos: $_todos, activeFilter: $_activeFilter)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is TodosState &&
        o._todoRepository == _todoRepository &&
        listEquals(o._todos, _todos) &&
        o._activeFilter == _activeFilter;
  }

  @override
  int get hashCode =>
      _todoRepository.hashCode ^ _todos.hashCode ^ _activeFilter.hashCode;
}
```

Notice that `loadTodos` has `Future<TodosState>` type whereas the other method `updateTodo`, `deleteTodo`, `toggleAll`, `clearCompleted` have `Stream<TodosState>` type. Why?

This can be understood from the user experience side. The user may want to fetch something from the backend and wait until the data to continue using the app. While waiting the user sees some waiting screen (CircularProgressIndicator).
In other scenarios, the user may want to update some data and Persist it, he wants the update to reflect instantly in the UI as if we are 100% sure that the backend will not fail. If data persistence fails then, you return back to the last state before the update and display some kind of SnackBar to inform the user of the error.

* In the first case, where we want to wait for the change, use a method that returns a Future.
    This is a common case when fetching for data form the backend
    ```dart
    //When we want to await for the future and display something in the screen,
    //we use future.
    static Future<TodosState> loadTodos(TodosState todosState) async {
        //states_rebuilder will notify observer widget with onWaiting state
        final _todos = await todosState._todoRepository.loadTodos();
        //if failure, states_rebuilder will notify observer widget with hasError state
        //if success, states_rebuilder will notify observer widget with hasData state
        return todosState.copyWith(
        todos: _todos,
        activeFilter: VisibilityFilter.all,
        );
    }
    ```

* In the second case where we want to display the updated date instantly and return back to the old state in case of failure, we use a method that returns a Stream.
    This a useful cas when updating deleting or adding data
    ```dart
    //We use stream generator when we want to instantly display the update, and execute the the saveTodos in the background,
    //and if the saveTodos fails we want to display the old state and a snackbar containing the error message
    //
    //Notice that this method is static pure function, it is already isolated to be tested easily
    static Stream<TodosState> addTodo(TodosState todosState, Todo todo) async* {
        final newTodos = List<Todo>.from(todosState._todos)..add(todo);
        yield* _saveTodos(todosState, newTodos);
    }

    static Stream<TodosState> _saveTodos(
    TodosState todosState,
    List<Todo> newTodos,
    ) async* {
        //Yield the new state, and states_rebuilder will rebuild observer widgets
        yield todosState.copyWith(
        todos: newTodos,
        );
        try {
        await todosState._todoRepository.saveTodos(newTodos);
        } catch (e) {
        //on error yield the old state, states_rebuilder will rebuild the UI to display the old state
        yield todosState;
        //rethrow the error so that states_rebuilder can display the snackbar containing the error message
        rethrow;
        }
    }
    ```
The other method are :
```dart
  static Stream<TodosState> updateTodo(
      TodosState todosState, Todo todo) async* {
    final newTodos =
        todosState._todos.map((t) => t.id == todo.id ? todo : t).toList();
    yield* _saveTodos(todosState, newTodos);
  }

  static Stream<TodosState> deleteTodo(
      TodosState todosState, Todo todo) async* {
    final newTodos = List<Todo>.from(todosState._todos)..remove(todo);
    yield* _saveTodos(todosState, newTodos);
  }

  static Stream<TodosState> toggleAll(TodosState todosState) async* {
    final newTodos = todosState._todos
        .map(
          (t) => t.copyWith(complete: !todosState.allComplete),
        )
        .toList();
    yield* _saveTodos(todosState, newTodos);
  }

  static Stream<TodosState> clearCompleted(TodosState todosState) async* {
    final newTodos = List<Todo>.from(todosState._todos)
      ..removeWhere(
        (t) => t.complete,
      );
    yield* _saveTodos(todosState, newTodos);
  }
```

This is all of what you expect to see in the service layer, just pure dart classes. 

# data_source
We will use the firebase cloud to save todos and firebase auth for authentication.

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
    * Sync mutation using the `state` getter and setter:
      ```dart
        _activeTabRM.state = AppTab.values[index];
      ```
    * Sync mutation using `setState` method:
    `setState` works well for primitive and immutable objects.
    It exposes the currentState and replace it with the new state after computation
      ```dart
        activeFilterRM.setState(
                (activeFilter currentFilter) => filter,
                onData: (context, data) {

                },
                onError : (context, error){

                }
              );
      ```
    * Async mutation using `future` method
    `setState` works well with futures. It await for the future to complete and notify observers with its ConnectionState.
    If all observer widgets are disposed and the future is still pending setSate will cancel the future because no observer is awaiting for the result.
      ```dart
        observe: () => RM.get<AuthState>()
            .setState(
              (authState) => AuthState.currentUser(authState),
               onError : ErrorHandler.showErrorDialog,
             ),
      ```
    * Async mutation using `stream` method
    `setState` works well with streams. `setState` subscribe to the stream and notify  observer widget with the emitted values.
    If all observer widget are removed from the widget, setSate will cancel the subscription it the ReactiveModel is local.
    For global models the stream is not cancelled until the Injector that created the stream is disposed from the widget tree.
     ```dart
        todosStateRM
                .setState((t) => TodosState.addTodo(t, todo),
                 onError : ErrorHandler.showErrorSnackBar,
                 );
      ```

## main.dart
[**lib\main.dart**](lib\main.dart)


## injected.dart
[**lib\injected.dart**](lib\injected.dart)
```dart
final authRepository = RM.inject<IAuthRepository>(() => AuthRepository());

final authState = RM.inject<AuthState>(
  () => InitAuthState(authRepository.state),
);

//When the authState change the user, the TodosRepository is 
//er-instantiated to account for the new suer
final todosRepository = RM.injectComputed<ITodosRepository>(
  compute: (_) => TodosRepository(
    user: authState.state.user,
  ),
);

//When the TodosRepository is changed, the TodosState is 
//changed to account for the new TodosRepository
final todosState = RM.injectComputed<TodosState>(
  compute: (s) => s.copyWith(
    todoRepository: todosRepository.state,
  ),
  initialState: TodosState(
    todos: [],
    activeFilter: VisibilityFilter.all,
    todoRepository: todosRepository.state,
  ),
);

final activeTab = RM.inject(() => AppTab.todos);
```


## app.dart
**lib\app.dart**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const App();
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











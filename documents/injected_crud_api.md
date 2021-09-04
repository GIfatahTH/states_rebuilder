//OK
Retrieving, submitting, or deleting data from a backend service or local database is a common task in all non-trivial applications. Often the extracted data is organized into tables and records and follows the pair (List of something - something). For example:
* (Products - Product),
* (Todos - Todo),
* (Posts - Post),
* (Items - Item).

In such a situation, we are interested in four operations:
- CREATE: create a new record. (New product, todo, post, or item).
- READ: Get a list of records (list of products, tasks, posts, or items).
- UPDATE: update a list of records.
- DELETE: delete a list of records.

`RM.injectCRUD` hides the detailed implementation of the  (Items-Item) CRUD operations and exposes a clean API:
- to inject the state of `List<Item>`;
- to perform the CRUD operation and;
- to mutate the state and notify listeners in an optimistic or pessimistic manner;
- to easily test and mock dependencies.


# Table of Contents <!-- omit in toc --> 
- [**Implement the ICRUD interface**](#Implement-the-ICRUD-interface)  
- [**InjectCRUD**](#InjectCRUD)  
  - [**repository**](#repository)  
  - [**param**](#param)   
  - [**readOnInitialization**](#readOnInitialization)   
  - [**onCRUD for side effects**](#onCRUD-for-side-effects)   
- [**CREATE**](#CREATE)   
  - [**item**](#item)   
  - [**param**](#param)   
  - [**isOptimistic**](#isOptimistic)   
  - [**onStateState**](#onStateState)   
  - [**onCRUD for side effects**](#onCRUD-for-side-effect)   
- [**READ**](#READ)  
  - [**middleState**](#middleState)   
- [**update**](#update)   
  - [**where**](#where)   
  - [**set**](#set)   
- [**delete**](#delete)   
  - [**where**](#where)  
- [**Inherited item**](#Inherited-item)
  - [**inherited**](#inherited)
  - [**call(context)**](#call(context))
  - [**of(context)**](#of(context))
  - [**reInherited**](#reInherited)
- [**OnCRUDBuilder**](#OnCRUDBuilder)
- [**Get the repository**](#Get-the-repository)   
  - [**getRepoAs**](#getRepoAs)   
- [**Testing and injectCRUDMock**](#Testing-and-injectCRUDMock)   
   


## Implement the ICRUD interface
First you have to implement the `ICRUD` interface: 

```dart
class MyItemsRepository implements ICRUD<Item, Param> {
  @override
  ICRUD<void> init()async{
    //initialize any plugging here
  }

  @override
  Future<List<Item>> read(Param? param) async {
    final items = await http.get('uri/${param.user.id}');
    //After parsing
    return items;

    //OR
    // if(param.queryType=='GetCompletedItems'){
    //    final items = await http.get('uri/${param.user.id}/completed');
    //    return items;
    // }else if(param.queryType == 'GetActiveItems'){
    //   final items = await http.get('uri/${param.user.id}/active');
    //    return items;
    // }
  }
  @override
  Future<Item> create(Item item, Param? param) async {
    final result = await http.post('uri/${param.user.id}/items');
    return item.copyWith(id: result['id']);
  }

  @override
  Future<dynamic> update(List<Item> items, Param? param) async {
    //Update items
    return numberOfUpdatedRows;
  }
  @override
  Future<dynamic> delete(List<Item> items, Param? param) async {
    //Delete items
  }

  @override
  void dispose() {
    //Cleaning resources
  }

// You can add here custom methods to perform other requests to the backend
  
}
```

This is an example of a Todos app using Sqflite.
<details>
  <summary>Click to expand!</summary>



```dart
///Class used to parametrizes the query
class TodoParam {
  ///filter can be all, active or completed
  final VisibilityFilter filter;
  TodoParam({this.filter});
}

class SqfliteRepository implements ICRUD<Todo, TodoParam> {
  Database _db;
  final _tableName = 'todos';

  Future<void> init() async {
    //Initialize the data base
    final databasesPath =
        await path_provider.getApplicationDocumentsDirectory();
    _db = await openDatabase(
      join(databasesPath.path, 'todo_db.db'),
      version: 1,
      onCreate: (db, ver) async {
        await db.execute(
          'CREATE TABLE $_tableName (id TEXT PRIMARY KEY, task TEXT, note TEXT, complete INTEGER)',
        );
      },
    );
  }

  @override
  Future<List<Todo>> read(TodoParam param) async {
    try {
      var result;
      if (param.filter == VisibilityFilter.all) {
        result = await _db.query(_tableName);
      } else {
        result = await _db.query(
          _tableName,
          where: 'complete = ?',
          whereArgs: [param.filter == VisibilityFilter.active ? '0' : '1'],
        );
      }

      if (result.isNotEmpty) {
        return result.first['value'];
      }
      return null;
    } catch (e) {
      //Just throw custom exception and they will be handle for you
      throw PersistanceException('There is a problem in reading');
    }
  }

  @override
  Future<Todo> create(Todo item, TodoParam param) async {
    try {
      await _db.insert(_tableName, item.toMap());
      return item;
    } catch (e) {
      throw PersistanceException('There is a problem in writing ');
    }
  }

  @override
  Future<dynamic> delete(List<Todo> items, TodoParam param) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [items.first.id],
    );
    return true;
  }

  @override
  Future<dynamic> update(List<Todo> items, TodoParam param) async {
    await _db.update(
      _tableName,
      items.first.toMap(),
      where: 'id = ?',
      whereArgs: [items.first.id],
    );
    return true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  //You are not limited to the six overridden methods.
  //You can add your custom ones.
  Future<int> count(TodoParam param) async {
    try {
      var result;

      result = await _db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName'
        'WHERE complete = ${param.filter == VisibilityFilter.active ? '0' : '1'}',
      );

      if (result.isNotEmpty) {
        return result.first['value'];
      }
      return null;
    } catch (e) {
      throw PersistanceException('There is a problem in reading');
    }
  }
}

```
</details>

## InjectCRUD

suppose our InjectedCRUD state is assigned to the `products` variable.


```dart
InjectedCRUD<T, P>  products = RM.injectCRUD<T, P>(
  ICRUD<T, P> Function() repository, {
    P Function()? param, 
    bool readOnInitialization = false, 
    _OnCRUD<void>? onCRUD, 
    //Similar to any Injected
    SnapState<T> Function(MiddleSnapSate<List<T>>) middleSnapState,
    void Function(List<T>)? onInitialized, 
    void Function(List<T>)? onDisposed, 
    On<void>? onSetState, 
    DependsOn<List<T>>? dependsOn, 
    int undoStackLength = 0, 
    PersistState<List<T>> Function()? persist, 
    bool autoDisposeWhenNotUsed = true, 
    bool isLazy = true, 
    String? debugPrintWhenNotifiedPreMessage,
    })
```
### repository:
This is the repository that implements the `ICRUD` interface.

### param:
This is the default `param`. It is used to configure the queries that are sent to the backend or the local database. It can contain the user's information and token to use in the request URL. The `create`, ` read`, `update`, and` delete` methods can override it. (See later).

### readOnInitialization
If set to true, a `read` query is sent using the default `param` when the state is first initialized. The default value is false.

For the remainder of the parameters see [`Injected` API](rm_injected_api).

> Notice that the state of the `InjectedCRUD<T, Param>` is of type `List<T>`.

### OnCRUD for side effects
It is used for side effects. It offers three hooks:
- onWaiting: while the database is querying. 
- onError: if the query ends with error
- onResult; if the request ends successfully. It exposes the result fo the query (ex: number of rows updated).

#### `OnCRUD` vs `onSetState`:
- Both used for side effects.
- In pessimistic mode they are equivalent.
  - In `OnCRUD` the onWaiting is called while waiting for the backend service result.
- In optimistic mode, the difference is in the onWaiting hook.
  - In `onSetState` the onWaiting in never called.
- OnsetState has onData callback.
- `OnCRUD` has onResult callback that exposes the return result for the backend service.



## CREATE
To create an item and add it to the state, we use the `create` method.


```dart
Future<T?> products.crud.create(
    T item, {
    P Function(P? param)? param,
    T Function(T state, T nextState) middleState,
    bool isOptimistic = true,
    On<void>? onSetState, 
    void Function(dynamic result)? onResult,
    
})
```
### item
The first required parameter is the item to add.
### param
If param is not defined the default param defined when injecting the state is used. 

The exposed `parm` in the callback is the default `param`, you can use it and copy it to return a new `param` to be used for this particular call.

### isOptimistic
By default, the `create`, `update` and `delete` methods are optimistic. This means that the state changes to the new one before sending the query to the backend or to the database service. Listeners are notified to rebuild for the new state. !then, the query is sent in the background and if it succeeds nothing will change. Only if a failure occurs, the old state is recovered and listeners are notified to use the old state with the thrown error.
In case you want to wait for the query to end, for example, to get an ID from the backend service, you can set the `isOptimistic` to false. In this case, the state status is changed to `isWaiting`, and listeners are notified. When data is ready, the state changes to add the item and the state status is `hasData`.

> Notice that the state is mutated and listeners are notified without using the `setState` method.

### onStateState
Similar to setState defined in the `RM.injectCRUD`.

### onResult
Invoked after the backend query ends usefully and exposed the return result. The return result may contain information on the last id added, number of item updated or deleted.

Example from todo app:
```dart
//It uses the default param
 todos.crud.create(Todo(_task, note: _note));
```

## READ
To READ from the backend or database and mutate the state and notify listeners, we use the `read` method.
### middleState
It is a callback that exposes the current list of items just before mutation and the list of items that results from querying the backend service and returns a new list of times to be used to mutate the state.

If not defined the state will be mutated to hold the new obtained list of items. If you want to append the new list of items to the old one :

```dart
  product.crud.read(
   middleState: (state, nextState) {
     return [..state, ...nextState];
   }
  )
```

### onStateStatek
Similar to setState defined in the `RM.injectCRUD`.

### onCRUD for side effects
Similar to setState defined in the `RM.injectCRUD`.[See here](#onCRUD)



```dart
Future<List<T>> products.crud.read({
  P Function(Param? param)? param,
  On<void>? onSetState, 
  })
```
If `param` is not defined the default `param` as defined when injecting the state is used. 

The exposed Parm in the callback is the default `param`, you can use it to copy it and return a new `param` to be used for this particular call.

Example from todo app:

```dart
PopupMenuButton<VisibilityFilter>(
    onSelected: (filter) {
      //Send a read query with the chosen filter
      todos.crud.read(param: (param) => param.copyWith(filter: filter));
    },
   .
   .

)      
```
Notice that the state status of products will change to `isWaiting` and notifies listeners to rebuild. after data is returned, the state is mutated to hold the new list of products and the state status will change to `hasData` and the listeners are notified.

## update
```dart
Future<void> products.crud.update({
  required bool Function(T item) where, 
  required T Function(T item) set, 
  //Similar to create method
  P Function(P? param)? param, 
  On<void>? onSetState, 
  void Function(dynamic result)? onResult,
  bool isOptimistic = true
})     
```
### where
It's a callback that exposes an item from the list and returns true if the item will be updated. `where` will be executed for all items in the list to select those that will be updated.

### set
It is a callback that exposes the elements to be updated and return the new ones.

> Notes that the state will be mutated immutably. That is a new list is return after the state is updated.

> The internal logic is optimized to iterate only once throw the list of products.

Example from todo app:

```dart
void updateTodo(Todo newTodo){
  todos.crud.update(
    where: (t) => t.id == newTodo.id,
    set: (t) => newTodo,
  );
}
```
## delete
```dart
Future<void> products.crud.delete({
    required bool Function(T item) where,
    //Similar to create method
    P Function(P? param)? param,
    On<void>? onSetState, 
    void Function(dynamic result)? onResult,
    bool isOptimistic = true,
  
})     
```
### where
It is a callback that exposes an element from the list and returns true if the element will be deleted.
`where` will be executed for all the elements of the list to chose those that will be deleted.

Example from todo app:

```dart
void removeTodo(Todo todo) {
  todos.crud.delete(
    where: (t) => t.id == todo.id,
  );
}
```

## Inherited item
Working with a list of items, we may want to display them using the `ListView` widget of Flutter. At this stage, we are faced with some problems regarding :
- performance: Can we use the `const` constructor for the item widget. Then, how to update the item widget if the list of items updates.
- Widget tree structure: What if the item widget is a big widget with its nested widget tree. Then, how to pass the state of the item through the widget three? Are we forced to pass it through a nest tree of constructors?
- State mutation: How to efficiently update the list of items when an item is updated.

InjectedCRUD, solves those problems using the concept of inherited injected as described in [the widget-wise state section](state_widget_wise_api)

### inherited
```dart
products.inherited({
    required Key  key,
    required T Function()? item,
    required Widget Function(BuildContext) builder,
    String? debugPrintWhenNotifiedPreMessage,
 })
```
Key is required here because we are dealing with a list of widgets with a similar state.

Example:
```dart
Widget build(BuildContext context) {
  return OnReactive(
       ()=>  ListView.builder(
          itemCount: products.state.length,
          itemBuilder: (context, index) {
            //Put InheritedWidget here that holds the item state
            return todos.item.inherited(
              key: Key('${products.state[index].id}'),
              item: () => products.state[index],
              builder: (context) => const ProductItem(),//use of const
            );
          },
        );
  );
```
In the ListBuilder, we used the `inherited` method to display the` ItemWidget`. This has huge advantages:

- As the `inherited` method inserts an` InheritedWidget` above`ItemWidget`, we can take advantage of everything you know about` InheritedWidget`.
- Using const constructors for item widgets.
- Item widgets can be gigantic widgets with a long widget tree. We can easily get the state of an item and mutate it with the state of the original list of items even in the deepest widget.
- The `inherited` method, binds the item to the list of items so that updating an item updates the state of the list of items and sends an update request to the database. Likewise, updating the list of items will update the `ItemWidget` even if it is built with the const constructor.


### call(context)
From a child of the item widget, we can obtain an injected state of the item using the call method:
```dart
Inherited<T> product = products.item.call(context);
//item is callable object. `call` can be removed
Inherited<T> product = products.item(context);
```
You can use the injected product to listen to and mutate the state.

```dart
product.state = updatedProduct;
```
Here we mutated the state of one item, the UI will update to display the new state, and, **importantly, the list of items will update and update query with the default parameter is sent to the backend service.**

**Another important behavior is that if the list of items is updated, the item states will update and the Item Widget is re-rendered, even if it is declared with const constructor.** (This is possible because of the underlying InheritedWidget).

### of(context)
It is used to obtain the state of an item. The `BuildContext` is subscribed to the inherited widget used on top of the item widget,
```dart
T product = products.item.of(context);
```
> of(context) vs call(context):
>  - of(context) gets the state of the item, whereas, call(context) gets the `Injected` object.
>  * of(context) subscribes the BuildContext to the InheritedWidget, whereas call(context) does not.

### reInherited
As we know `InheritedWidget` cannot cross route boundary unless it is defined above the `MaterielApp` widget (which s a nonpractical case).

After navigation, the `BuildContext` connection loses the connection with the `InheritedWidgets` defined in the old route. To overcome this shortcoming, with state_rebuilder, we can reinject the state to the next route:

```dart
RM.navigate.to(
  products.item.reInherited(
     // Pass the current context
     context : context,
     //The builder method, Notice we can use const here, which is a big performance gain
     builder: (BuildContext context)=>  const NewItemDetailedWidget()
  )
)
```

## OnCRUDBuilder
As the CREATE, UPDATE, DELETE functions can be performed optimistically, the user will not notice anything. Looks like he's dealing with a simple sync list of items.

If we want to show the user that something is happening in the background, we can use the `OnCRUDBuilder` widget.

```dart
OnCRUDBuilder<T>(
  listenTo: products,
  onWaiting: ()=> Text('onWaiting'),
  onError: (err, refreshErr)=> Text('onError'),
  onResult: (result)=> Text('onResult'),
)
```
- onWaiting: while the database is querying. 
- onError: if the query ends with an error. IT exposes a refresher to reinvoke the async call that caused the error.
- onResult; if the request ends successfully. It exposes the result fo the query (ex: number of rows updated).

#### `OnCRUD` vs `On.all` or On.or:
- Both used to listen to injected state.
- In pessimistic mode they are equivalent.
- In optimistic mode, the difference is in the onWaiting hook.
  - In `On.all` the onWaiting in never called.
  - In `On.crud` the onWaiting is called while waiting for the backend service result.
- `On.all` has onData callback.
- `On.crud` has onResult callback that exposes the return result for the backend service.


## Get the repository
If you have custom methods defined in the repository, you can call them after you get the repository.
### getRepoAs

> Update: Before version 4.1.0 getRepoAs return a Future of the repository. And from version 4.1.0 the getRepoAs return the repository object.

Example from todo app:
```dart
//getting the repository
final repo =  todos.getRepoAs<SqfliteRepository>();
//call count method
return repo.count(
  TodoParam(filter: VisibilityFilter.completed),
);
```
## Testing and injectCRUDMock
> UPDATE: From version 4.1.0, default mock must be put inside the setUp method.

It's very easy to test an app built with states_rebuilder.
You just have to implement your repository with a fake implementation.

Example from todo app:
```dart
//Fake implementation of SqfliteRepository
class FakeTodoRepository implements SqfliteRepository {
  List<Todo> todos;
  //You can throw fake exceptions
  dynamic error;

  //You can add pre-stored todos
  FakeTodoRepository(this.todos);

  @override
  Future<void> init() async {}

  @override
  Future<Todo> create(Todo item, TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    todos = [...todos, item];
    return item;
  }

  @override
  Future<List<Todo>> read(TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));

    if (param.filter == VisibilityFilter.active) {
      return todos.where((e) => !e.complete).toList();
    }
    if (param.filter == VisibilityFilter.completed) {
      return todos.where((e) => e.complete).toList();
    }
    return [...todos];
  }

  @override
  Future update(List<Todo> items, TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }

    for (var item in items) {
      final index = todos.indexOf(item);
      assert(index != -1);
      todos[index] = item;
    }
  }

  @override
  Future delete(List<Todo> item, TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    todos = todos.where((e) => !item.contains(e)).toList();
  }

  @override
  Future<int> count(TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }

    if (param.filter == VisibilityFilter.active) {
      return todos.where((e) => !e.complete).length;
    }
    if (param.filter == VisibilityFilter.completed) {
      return todos.where((e) => e.complete).length;
    }
    return todos.length;
  }

  @override
  void dispose() {}
}
```
In test:

```dart
void main() async {
  setUp((){
    //Default and cross test mock must be put in the setUp method
    todos.injectCRUDMock(() => FakeTodoRepository());
  });

  testWidgets('test 1', (tester) async {
    .
    .
  });

  testWidgets('test 2', (tester) async {
    //mock with some stored Todos
    todos.injectCRUDMock(() => FakeTodoRepository([Todo(...), Todo(..)]));
    
    .
    .
  });

  testWidgets('test 3', (tester) async {
    .
    .
    final repo = await todos.getRepoAs<FakeTodoRepository>();
    repo.error = Exception('Fake network failure');
    .
    .
  });
```

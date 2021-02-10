

## `RM.injectCRUD` for Create, Read, Update and Delete from a backend service.
An application can be seen as a mean of visualizing raw stored data, and giving the user an interface to interact with it by reading, updating, creating, and deleting it. Data is usually stored in tables (Items) and a row represents an (Item).

`RM.injectCRUD` hides the detailed implementation of the CRUD operations and exposes a clean API:
- to inject the state of `List<Item>`;
- to perform the CRUD operation and;
- to mutate the state and notify listeners in an optimistic or pessimistic manner;
- to easily test and mock dependencies.

All what states_rebuilder asks you is to define:
- A data class that represents your data (a row in a table) and,
- A parameter class that holds parameters to be used in the backend querying. It may be a simple primitive (String, int ... )
- A class that implements an interface to tell states_rebuilder how to query your backend service. states_rebuilder do not and should not know any thing about your backend service.

Let's meet `RM.injectCRUD` with the following example:
### Data class
Suppose our data consists of a simple number with an id and it can be modeled by this data class:
```dart
class Number {
  final String id;
  final int number;
  Number({
    this.id,
    this.number,
  });

  Number copyWith({
    String id,
    int number,
  }) {
    return Number(
      id: id ?? this.id,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
    };
  }

  factory Number.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Number(
      id: map['id'],
      number: map['number'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Number.fromJson(String source) => Number.fromMap(json.decode(source));

  @override
  String toString() => 'Number(id: $id, number: $number)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Number && o.id == id && o.number == number;
  }

  @override
  int get hashCode => id.hashCode ^ number.hashCode;
}
//Tip: use dart data class generator extension of Vs code, to create copyWith, toJson, .. . . 
```
## Param class
A param class is a simple class, that holds the parameter of the query to be sent to the backend service. In our case, we need :
- The user id, because our data is scoped by user.
- And the number type, because we want to retrieve even, odd, or all numbers.
```dart
class ItemParam {
  final String userId;
  final NumType numType;
  ItemParam({
    this.userId,
    this.numType,
  });

  ItemParam copyWith({
    String userId,
    NumType numType,
  }) {
    return ItemParam(
      userId: userId ?? this.userId,
      numType: numType ?? this.numType,
    );
  }
}

enum NumType { even, odd, all }
```

### Implementation of the ICRUD class.
After defining your data and param classes, all you need to do is to implement the `ICRUD` interface.

You have six methods to implement:
- `init`: To initialize any plugins
- `create`, `read`, `update`, `delete` for CRUD operations
- `dispose`: to dispose of resources and some cleanup if necessary.
- You can add other custom methods for example for counting items.
The `ItemRepository` here is a fake implementation, You can substitute it with any real implementation for example for Sqflite, firebase, ....
```dart
class NumbersRepository implements ICRUD<Number, NumberParam> {
  Map<String, List<Number>> _numbersStore;

  @override
  Future<void> init() async {
    //Initialize the plugins
    await Future.delayed(Duration(seconds: 1));
    //Our fake store is pre-populated with two items.
    _numbersStore = {
      '1': [Number(id: '1', number: 0), Number(id: '2', number: 11)]
    };
  }

  @override
  Future<Number> create(Number number, NumberParam param) async {
    await Future.delayed(Duration(seconds: 1));
    final userNumbers = _numbersStore[param.userId] ?? [];
    _numbersStore[param.userId] = [...userNumbers, number];
    print(_numbersStore);
    return number;
  }

  @override
  Future<List<Number>> read(NumberParam param) async {
    await Future.delayed(Duration(seconds: 1));
    //fake random error to see how to recall the read after an error
    if (Random().nextBool()) {
      throw Exception('Error');
    }
    final userNumbers = _numbersStore[param.userId] ?? [];

    if (param.numType == NumType.even) {
      return userNumbers.where((e) => e.number % 2 == 0).toList();
    }
    if (param.numType == NumType.odd) {
      return userNumbers.where((e) => e.number % 2 == 1).toList();
    }
    return [...userNumbers];
  }

  @override
  Future update(List<Number> numbers, NumberParam param) async {
    await Future.delayed(Duration(seconds: 1));
    final userNumbers = _numbersStore[param.userId] ?? [];
    for (var number in numbers) {
      final index = userNumbers.indexWhere((e) => e.id == number.id);
      if (index < 0) {
        throw Exception('Can not update non exisiting number');
      }
      userNumbers[index] = number;
    }
    _numbersStore[param.userId] = [...userNumbers];
    print(_numbersStore);
  }

  @override
  Future delete(List<Number> numbers, NumberParam param) async {
    await Future.delayed(Duration(seconds: 1));
    final userNumbers = _numbersStore[param.userId] ?? [];
    for (var number in numbers) {
      final isRemoved = userNumbers.remove(number);
      if (!isRemoved) {
        throw Exception('Can not delete non exisiting number');
      }
    }
    _numbersStore[param.userId] = [...userNumbers];
    print(_numbersStore);
  }

  Future<int> count(NumberParam param) async {
    final userNumbers = _numbersStore[param.userId] ?? [];

    if (param.numType == NumType.even) {
      return userNumbers.where((e) => e.number % 2 == 0).length;
    }
    if (param.numType == NumType.odd) {
      return userNumbers.where((e) => e.number % 2 == 1).length;
    }
    return userNumbers.length;
  }

  @override
  void dispose() {}
}
```
That is the hard part of the journey; Creating a data and param class and implementing the `ICRUD` repository.

### Injecting the repository:

```dart
final numbers = RM.injectCRUD<Number,NumberParam>(
  () => NumbersRepository(),// implement ICRUD
  // The default param
  //User id is supposed to be obtained after authentication.
  //By default we want to retrieve all numbers
  param: () => NumberParam(userId: '1', numType: NumType.all),
  //We wan to send a read query with default param as soon as 
  //the numbers state is initialized
  readOnInitialization: true,
);
```

```dart
count state holds the count of numbers
final count = RM.injectFuture<List<int>>(
  //this is called the creation method
  () async {
    //the count method is a custom method that is not defined by the interface ICRUD.
    //To invoke it we need to get the NumbersRepository first
    final repo = await numbers.getRepoAs<NumbersRepository>();
    //Invoke count method for all, odd, and even.
    final all = repo.count(NumberParam(userId: '1', numType: NumType.all));
    final odd = repo.count(NumberParam(userId: '1', numType: NumType.odd));
    final even = repo.count(NumberParam(userId: '1', numType: NumType.even));
    //Futures are invoked in parallel
    return [await all, await odd, await even];
  },
  initialState: [0, 0, 0],
  //Depends on the number state, any time the state changes, the  creation 
  //method is recalculated.
  //We set shouldNotify to false while the number method is invoking of a CRUD method.
  //This is to make sure counts are calculated after data is persisted
  dependsOn: DependsOn({numbers}, shouldNotify: (_) => !numbers.isOnCRUD),
);
```
That's all, your logic is ready and your injected state is reactive and know how to crud your backend service.

### The UI
```dart
void main() => runApp(_App());
class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        appBar: _appBarMethod(), //read items
        body: _bodyMethod(), //listen, update and delete items
        floatingActionButton: buildFloatingActionMethod(), //add items
      ),
    );
  }
}


```
#### FloatingActionButton : CREATE Items
On `FloatingActionButton` tap, an optimistic READ query is sent to the backend service.
By optimistic READ, we mean that the the new item is added to the state, and the  listeners of the state are notified to rebuild before sending the query. In the background the query is sent and if it succeeded nothing will happen. Only if the backend service fails to add the item, the added item is removed from the state and a notification with error is sent to the listeners.

```dart
  FloatingActionButton buildFloatingActionMethod() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => numbers.crud.create(
        Number(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          number: DateTime.now().second,
        ),
      ),
    );
  }
```

To read the items, pessimistically, that is waiting for the query to end before updating the state, we set the isOptimistic flag to true:

```dart
onPressed: () => items.crud.create(
    Number(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        number: DateTime.now().second,
    ),
    isOptimistic : false,
),
```
That's all you need to create an item, update the state and notify listeners.

#### AppBar : READ Items
On app start, and when the items state is first initialized all numbers are fetched. 

In the AppBar we have three buttons to read (all, even, or odd) numbers
```dart
 AppBar _appBarMethod() {
    return AppBar(
      title: Text('InjectCRUD'),
      actions: [
        OutlineButton(
          child: Text('Even'),
          onPressed: () => numbers.crud.read(
            //copy the default param that holds the user id and changed
            //the number type
            param: (param) => param.copyWith(numType: NumType.even),
          ),
        ),
        OutlineButton(
          child: Text('Odd'),
          onPressed: () => numbers.crud.read(
            param: (param) => param.copyWith(numType: NumType.odd),
          ),
        ),
        OutlineButton(
          child: Text('All'),
          onPressed: () => numbers.crud.read(
            param: (param) => param.copyWith(numType: NumType.all),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size(20, 20),
        //Listen to count state and update to display new counts
        child: On.data(
          () => Row(
            children: [
              Text('All: ${count.state[0]}    '),// all count
              Text('Odd: ${count.state[1]}    '),//Odd count
              Text('Even: ${count.state[2]}    '),//Even count
            ],
          ),
        ).listenTo(count),
      ),
    );
  }
```
That's all to READ. Just use the `items.crud.read` method with optionally overriding the default query param. 

#### body : Listen to the state, UPDATE and DELETE
In the body of the `Scaffold` we will display the list of items, Listen the the `items` state and update and delete an item.
```dart
   Widget _bodyMethod() {
    //Listen to numbers state using On.or
    return On.or(
      onWaiting: () => Center(child: CircularProgressIndicator()),
      onError: (err) => Center(
        child: RaisedButton(
          child: Text('Refresh'),
          //If read fails, we can recall it again using the default params
          onPressed: () => numbers.refresh(),
        ),
      ),
      or: () => ListView.builder(
        itemCount: numbers.state.length,
        itemBuilder: (context, index) {
          //Display number items using the inherited method.
          //the inherited method, puts an InheritedWidget on top of
          //the ItemWidget.
          return numbers.item.inherited(
            key: Key('${numbers.state[index].id}'),
            item: () => numbers.state[index],
            //Notice const here
            builder: (context) => const ItemWidget(),
          );
        },
      ),
    ).listenTo(numbers);
  }
```
In the ListBuilder we used the `inherited` method to display the `ItemWidget`. This has a huge benefits:
- As the `inherited` method inserts an `InheritedWidget` on top of`ItemWidget`, we can take advantage of all you know of the `InheritedWidget`.
- Using const constructors for item widget.
- Item Widgets can be a gigantic widgets with long widget tree. We can easily obtain the state of an item and mutate it with the state of the original list of items.
- `inherited` methods, links the item to the list of items, so that updating an item will update the List of items state and sends an update query to the database. In similar manner, updating the list of items will update the `ItemWidget` even if constructed with the const constructor. 

```dart
class ItemWidget extends StatelessWidget {
  const ItemWidget();
  @override
  Widget build(BuildContext context) {
    //Obtain the state of one item using the .call(context). It relays on the 
    //Inherited widget mechanisms
    final item = numbers.item(context);
    return ListTile(
      title: On.data(
        () => Text('${item.state.number}'),
      ).listenTo(item),// listen to the obtained itme
      leading: const ChildItemWidget(), // another child widgets (DELETE  item)
      trailing: IconButton(
        icon: Icon(Icons.update),

        // updating the list of numbers ==> update the ItemWidget even if const
        /*
        onPressed: () => numbers.crud.update(
          where: (e) => e.id == item.state.id,
          set: (e) => e.copyWith(number: e.number + 1),
        ),
        */

        // updating an item ==> updates the list of items and sends update query
        //to the data base
        onPressed: () => item.setState(
          //update here must be immutable
          (s) => s.copyWith(
            number: s.number + 1,
          ),
        ),
      ),
    );
  }
}
```

In the second opPressed callback, we simply immutably update the state of the obtained item. As the state of one item is linked to the state of the list of items, the latter will update and an UPDATE query will be fired to the database.

In the first onPressed (the commented one), we update the list using the `item.update` method :
```dart
onPressed: () => numbers.crud.update(
    where: (e) => e.id == item.state.id,
    set: (e) => e.copyWith(number: e.number + 1),
),
```
The ItemWidget will render the new updated list of items even though it is created using the const constructors.

```dart
class ChildItemWidget extends StatelessWidget {
  const ChildItemWidget();
  @override
  Widget build(BuildContext context) {
    //Getting the item using of(context)
    //We can use call(context) here
    final item = numbers.item.of(context);
    return IconButton(
      icon: Icon(Icons.delete),
      //deleting items the fulfill the where condition
      onPressed: () => numbers.crud.delete(
        where: (e) => e.id == item.id,
      ),
    );
  }
}
```
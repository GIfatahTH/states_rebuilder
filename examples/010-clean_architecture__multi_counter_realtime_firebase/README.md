# clean_architecture_andrea_multi_counter_with_firebase

This app consists of a list of counters, where we can increment/decrement a counter add a counter or delete one counter. The app is connected with realtime firebase store.

Actually we will build the app with two flavor environments, one with real firebase connection for production and the other with a fake data base mimicking firebase for development.

To read more on how to create flavors for Flutter [hit this link](https://flutter.dev/docs/deployment/flavors).

devolvement flavor
![counter_firebase_fake](https://github.com/GIfatahTH/repo_images/blob/master/010-multi_counter_realtime_firebase2.gif).

production flavor
![counter_firebase_real](https://github.com/GIfatahTH/repo_images/blob/master/010-multi_counter_realtime_firebase1.gif).

The architecture consists of something like onion layers, the innermost one is the domain layer, the middle layer is the service layer and the outer layer consists of three parts: the user interface  UI, data_source and infrastructure. Each of the parts of the architecture is implemented using folders.

![Clean Architecture](https://github.com/GIfatahTH/repo_images/blob/master/008-Clean-Architecture.png).

Code dependencies can only point inwards. Nothing in an inner circle can know anything at all about something in an outer circle. In particular, the name of something declared in an outer circle must not be mentioned by the code in the inner circle. In particular data_source and infrastructure must implement interfaces defined in the service layer.

```
**lib -**  
    | **- domain**  
    |        | **- entities :** (mutable objects with unique IDs.  
    |        |              They are the in-memory representation of   
    |        |              the data that was retrieved from the persistence   
    |        |              store (data_source))  
    |        |   
    |        | **- value objects :** (immutable objects which have value equality   
    |        |                      and self-validation but no IDs)  
    |        |   
    |        | **- exceptions :** (all custom exceptions classes that can be   
    |        |                      thrown from the domain)  
    |        |  
    |        | **- common :** (common utilities shared inside the domain)  
    |   
    | **- service**  
    |        | **- interfaces :** (interfaces that should any external service implements)  
    |        |   
    |        | **- exceptions :** (all custom exceptions classes that can be thrown   
    |        |                    from the service, infrastructure and data_source)  
    |        |   
    |        | **- common :**(common utilities shared inside the service)   
    |        |   
    |        | **- use case classes  
    |  
    | **-data_source** : (implements interfaces and throws exception defined in   
    |        |                the service layer. It is used to fetch and persist data  
    |        |                and instantiate entities and value objects)  
    |  
    | **-infrastructure** : (implements interfaces and throws exception defined in   
    |        |                the service layer. It is used to call third party libraries   
    |        |                to communicate with the underplaying infrastructure framework for
    |        |               example making a call or sending a message or email, using GPS.... )  
    |         
    | **UI**  
    |        | **- pages** :(collection of pages the UI has).  
    |        |   
    |        | **- widgets**: (small and reusable widgets that should be app independent. 
    |        |                 If you use a widget from external libraries, put it in this folder
    |        |                 and adapt its interface, 
    |        |   
    |        | **- exceptions :** (Handle exceptions)  
    |        |   
    |        | **- common :**(common utilities shared inside the ui)  
```

For more detail on the implemented clean architecture read [this article](https://medium.com/flutter-community/clean-architecture-with-states-rebuilder-has-never-been-cleaner-6c9b91c3b9b6#a588)


>For this kind of architectures, you have to start codding from the domain because it is totally independent from other layers. Then, go up and code the service layer and the data_source and the infrastructure. The UI layer is the last layer to code.

>Even if you want to understand an app scaffold around this kind of architecture, start understanding the domain then the service, that the data_source and infrastructure and end by understanding the UI part.

# Domain
## Entities
> Entities are mutable objects with unique IDs. They are the in-memory representation of the data that was retrieved from the persistence store (data_source). They must contain all the logic it controls. They should be validated just before persistence.

There is one entity 'Counter'.
### User entity :
**file:lib/domain/entities/counter.dart**

```dart
class Counter {
  Counter({this.id, this.value});
  int id;
  int value;
}
```
This is the simply all what we have for the domain layer.

# service

## interfaces
One of the major responsibilities of the service layer is to define a set of interfaces, the data_source and the infrastructure part of the outer layer must implement to be compatible to be used in the app.

We have one abstract classes that define all the CRUD operation:

**file:lib/service/interfaces/i_counter_repository.dart**

```dart
abstract class ICounterRepository {
  Future<void> createCounter();
  Future<void> setCounter(Counter counter);
  Future<void> deleteCounter(Counter counter);
  Stream<List<Counter>> countersStream();
}
```
**file:lib/service/counters_service.dart**

CountersService role is to hole the registered counter list and delegate to `ICounterRepository` for CRUD operations

```dart
class CountersService {
  final ICounterRepository _counterRepository; 

  //CountersService class depends on the ICounterRepository
  CountersService(this._counterRepository);

  void createCounter() async {
    await _counterRepository.createCounter();
  }

  void increment(Counter counter) async {
    counter.value++;
    await _counterRepository.setCounter(counter);
  }

  void decrement(Counter counter) async {
    counter.value--;
    await _counterRepository.setCounter(counter);
  }

  void delete(Counter counter) async {
    await _counterRepository.deleteCounter(counter);
  }

  Stream<List<Counter>> countersStream() {
    return _counterRepository.countersStream();
  }
}
```

That is the application service layer which defines the use cases.

# data_source

Here we have two implementations of the `ICounterRepository`, one fake for the dev flavor and the other is real firebase for prod flavor.

**lib\data_source\counter_fake_repository.dart**
```dart
//Fake data_source
class CounterFakeRepository implements ICounterRepository {

  StreamController<List<Counter>> _controller = StreamController();

  CounterFakeRepository() {
    _init();
  }

  //simulate initial load of the data
  Future<void> _init() async {
    await Future.delayed(Duration(seconds: 2));
    _controller.sink.add(_counters.values.toList());
  }

  @override
  Stream<List<Counter>> countersStream() {
    return _controller.stream;
  }

  @override
  Future<void> createCounter() async {
    await Future.delayed(Duration(milliseconds: 200));
    _counters[++_id] = Counter(id: _id, value: 0);
    _controller.sink.add(_counters.values.toList());
  }

  @override
  Future<void> deleteCounter(Counter counter) async {
    await Future.delayed(Duration(milliseconds: 200));
    _counters.remove(counter.id);
    _controller.sink.add(_counters.values.toList());
  }

  @override
  Future<void> setCounter(Counter counter) async {
    await Future.delayed(Duration(milliseconds: 200));
    _counters[counter.id] = counter;
    _controller.sink.add(_counters.values.toList());
  }


  int _id = 1000000000001;

  Map<int, Counter> _counters = {
    1000000000001: Counter(id: 1000000000001, value: 0)
  };

  void dispose() {
    _controller.close();
  }
}
```

**lib\data_source\counter_firebase_repository.dart**

I assume that you are successfully configure firebase for your app.

```dart
class CounterFirebaseRepository implements ICounterRepository {
  //Get a DatabaseReference for the counters path
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference().child('counters');

  @override
  Stream<List<Counter>> countersStream() {
    Stream<List<Counter>> stream;

    //Map the onValue stream to return a stream of list of counters
    stream = databaseReference.onValue.map((event) {
      Map<dynamic, dynamic> values = event.snapshot.value;
      if (values == null) {
        return [];
      }
      Iterable<String> keys = values.keys.cast<String>();

      List<Counter> counters = keys
          .map((key) => Counter(id: int.parse(key), value: values[key]))
          .toList();

      return counters ?? [];
    });

    return stream;
  }

  @override
  Future<void> createCounter() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    Counter counter = Counter(id: now, value: 0);
    await setCounter(counter);
  }

  @override
  Future<void> setCounter(Counter counter) async {
    await databaseReference.child('${counter.id}').set(counter.value);
  }

  @override
  Future<void> deleteCounter(Counter counter) async {
    await databaseReference.child('${counter.id}').remove();
  }
}
```

As simple as that. At this point we have set all the logic of our app. This is the portable part of the app that is independent of the UI framework (Flutter in our case). As I said you have to understand this part before digging into the UI layer.

# UI:

As state at the beginning our app will run in tow flavors, one for production and the other for devolvement.

* The production flavor use realtime firebase, blue primarySwatch color and the app title is "Production flavor"

* The development flavor use fake database, orange primarySwatch color and the app title is "Development flavor"

In the common folder let's define a config file

**lib\ui\common\config.dart**

```dart
// defining the config interface
abstract class IConfig {
  MaterialColor get primarySwatch;
  String get appTitle;
}

//the production config implementation
class ProdConfig extends IConfig {
  @override
  String get appTitle => 'Production flavor';

  @override
  MaterialColor get primarySwatch => Colors.blue;
}

//the production config implementation
class DevConfig extends IConfig {
  @override
  String get appTitle => 'Development flavor';

  @override
  MaterialColor get primarySwatch => Colors.orange;
}
```

Let's define a helper enum for flavors:

```dart
enum Flavor { Prod, Dev }
```

Then, we add two starting app files:

**lib\main_prod.dart**
```dart
//to run the app use : flutter run  -t lib/main_prod.dart
void main() {
  Injector.env = Flavor.Prod;
  runApp(new MyApp());
}
```

**lib\main_dev.dart**
```dart
//to run the app use : flutter run  -t lib/main_dev.dart
void main() {
  Injector.env = Flavor.Dev;
  runApp(new MyApp());
}
```

> `Injector.env` is a `states_rebuilder`  static field that holds a reference to the flavor environment.

**lib\my_app.dart**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //Register Two implementation of IConfig interface
        //Depending on the value of Injector.env one of them is instantiated.
        Inject<IConfig>.interface({
          Flavor.Prod: () => ProdConfig(),
          Flavor.Dev: () => DevConfig(),
        }),
        //Register Two implementation of ICounterRepository interface
        //The generic type is inferred by dart
        Inject.interface({
          Flavor.Prod: () => CounterFirebaseRepository(),
          Flavor.Dev: () => CounterFakeRepository(),
        }),
        //Inject the CountersService class with Its dependency
        Inject(() => CountersService(Injector.get())),
        //Inject the countersStream.
        Inject.stream(() => Injector.get<CountersService>().countersStream())
      ],
      builder: (context) {
        return MaterialApp(
          title: 'Multiple counters',
          theme: ThemeData(
            //get the primarySwatch color from the Config file
            primarySwatch: Injector.get<IConfig>().primarySwatch,
          ),
          home: HomePage(),
        );
      },
    );
  }
}
```

With states_rebuilder to inject and register against an interface you can simply use

```dart
Injector(
    inject:[
        Inject<Interface>(()=>Implementation()),
    ]
)
```
This is useful If you have on Implementation. In the future, you can easily use another implementation without braking the app.

The second approach, is useful if you want to use flavors:
```dart
Injector(
    inject:[
        Inject<Interface>.interface({
            'flavor1': ()=> Implementation1(),
            'flavor2': ()=>Implementation1(),
        }
      ),
    ]
)
```
If you use the latter approach you have to define the `Injector.env` before runApp method.

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //get the appTitle for the config file
        title: Text(Injector.get<IConfig>().appTitle),
        elevation: 1.0,
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          //getting the registered CountersService instance and call createCounter method
          Injector.get<CountersService>().createCounter();
        },
      ),
    );
  }

  Widget _buildContent() {
    //Use WhenRebuilderOr to subscribe to the stream and display onWaiting, onError and default builder widgets
    return WhenRebuilderOr<List<Counter>>(
      models: [Injector.getAsReactive<List<Counter>>()],
      onWaiting: () => Center(child: CircularProgressIndicator()),
      onError: (error) => Center(child: Text(error.toString())),
      builder: (_, countersStream) {
        final counters = countersStream.snapshot.data;
        if (counters.length > 0) {
          return ListView.builder(
            itemCount: counters.length,
            itemBuilder: (context, index) {
              final counter = counters[index];
              return CounterListTile(
                key: Key('counter-${counter.id}'),
                counter: counter,
              );
            },
          );
        }
        return Center(
          child: Text('You have no counter yet, please add a Counter.'),
        );
      },
    );
  }
}
```

Here We used the WhenRebuilderOR widget instead of whenRebuilder widget because we do not want to define the onIdle case, which is unreachable case.

>WhenRebuilder is used if you want to go through all the four possible state (onIdle,onWaiting,onError and onData).
>WhenRebuilderOr is preferred if you do not want to go through all the possible state and the builder will take the default non defined state

The `CounterListTile` is defined in the **lib\ui\pages\home_page\list_items_builder.dart** file

```dart
class CounterListTile extends StatelessWidget {
  CounterListTile({
    this.key,
    this.counter,
  });
  final Key key;
  final Counter counter;

  final countersService = Injector.get<CountersService>();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: key,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => countersService.delete(counter),
      child: ListTile(
        title: Text(
          '${counter.value}',
          style: TextStyle(fontSize: 48.0),
        ),
        subtitle: Text(
          '${counter.id}',
          style: TextStyle(fontSize: 16.0),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CounterActionButton(
              iconData: Icons.remove,
              onPressed: () => countersService.decrement(counter),
            ),
            SizedBox(width: 8.0),
            CounterActionButton(
              iconData: Icons.add,
              onPressed: () => countersService.increment(counter),
            ),
          ],
        ),
      ),
    );
  }
}
```

`CounterActionButton` is in the widget folder because it is generic and independent from any app specific logic. This widget can be used in other apps.

**lib\ui\widgets\counter_action_button.dart**

```dart
class CounterActionButton extends StatelessWidget {
  CounterActionButton({this.iconData, this.onPressed});
  final VoidCallback onPressed;
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28.0,
      backgroundColor: Theme.of(context).primaryColor,
      child: IconButton(
        icon: Icon(iconData, size: 28.0),
        color: Colors.black,
        onPressed: onPressed,
      ),
    );
  }
}
```

to run the production flavor : flutter run  -t lib/main_prod.dart
to run the devolvement flavor : flutter run  -t lib/main_dev.dart

This example is inspired from the work of Andrea Bizzotto https://github.com/bizz84/multiple-counters-flutter






# multi_future_counter_with_error

This example is a continuation from the [double_future_counter_with_error](https://github.com/GIfatahTH/states-rebuilder-examples/tree/master/002-double_future_counter_with_error).

In this example, we will refactor the code of [double_future_counter_with_error](https://github.com/GIfatahTH/states-rebuilder-examples/tree/master/002-double_future_counter_with_error) so that it will be reusable and will display four instance of it in a GridView :

<image src="https://github.com/GIfatahTH/repo_images/blob/master/005-multi_double_counter_with_error_1.png" width="300"/>

The app has `Scaffold`  with an `AppBar` and its body contains four quarters (counters); each within its own `Scaffold`.

The state management requirements are very complicated : 
1- We want each quarter (counter) to be independent;
2- If any quarter (counter) has an error, we want its own `AppBar` to be red and we want to show a `SnackBar` containing the error message;
3- We want the application appBar to display the tapped quarter (counter) name with its status (waiting);
4- We want the appBar to display a red error message if at least one counter has and error.

Here is the final GIF we want to get:

<image src="https://github.com/GIfatahTH/repo_images/blob/master/007-grid_counter_with_reactive_environnement_after.gif" width="300"/>


# Model

*file : counter.dart*

```dart
class Counter {
  Counter(this.count);
  int count;

  void increment() {
    count++;
  }
}
```

# Error
To handle error it is very convenient to use your custom error classes.

*file : counter_error.dart*

```dart
class CounterError extends Error {
  final String message = 'A permission issue, please contact your administrator';
}
```



# Service
The role of the `CounterService` class is to instantiate the counter (usually via the repository) and define the use cases to be used by the user interface.


```dart
import 'dart:math';

import 'counter.dart';
import 'counter_error.dart';

class CounterService {
  CounterService() {
    counter = Counter(0);
  }
  Counter counter;

  Future<void> increment(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));

    if (Random().nextBool()) {
      throw CounterError();
    } 
    
    counter.increment();
  }
}
```
`increment` method takes the second of the waiting as parameter.

>This is all the business logic of your app. It is testable, maintainable and framework independent. 

# User Interface

## Shared reactive environment (polluted environment):

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class CounterGridPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      //NOTE1: Injecting the CounterService.
      inject: [Inject(() => CounterService())],
      builder: (BuildContext context) {
        //NOTE2: Obtaining the registered reactive singleton.
        final counterServiceRM =
            Injector.getAsReactive<CounterService>(context: context);

        return Scaffold(
          appBar: AppBar(title: Text('Future counter with error')),


          body: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            children: <Widget>[

              //Note3 CounterApp Widget
              CounterApp(
                counterServiceRM: counterServiceRM,
                name: 'Counter 1',
              ),
              CounterApp(
                counterServiceRM: counterServiceRM,
                name: 'Counter 2',
              ),
              CounterApp(
                counterServiceRM: counterServiceRM,
                name: 'Counter 3',
              ),
              CounterApp(
                counterServiceRM: counterServiceRM,
                name: 'Counter 4',
              ),
            ],
          ),
        );
      },
    );
  }
}
```

After injecting the `CounterService` [NOTE1], we get its registered reactive singleton using `Injector.getAsReactive` method [NOTE2]. 

The `GridView` displays four `CounterApp` widgets: 

```dart
class CounterApp extends StatelessWidget {
  const CounterApp({Key key, this.counterServiceRM, this.name}) : super(key: key);
  final ReactiveModel<CounterService> counterServiceRM;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Theme(
        data: ThemeData(
            //NOTE1 : Set the primarySwatch color to red if the reactive instance has an error
            primarySwatch:
                counterServiceRM.hasError ? Colors.red : Colors.lightBlue),
        child: Scaffold(
          appBar: AppBar(
            title: Text(name),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //NOTE2 : CounterBox widget. Blue counter with one second of waiting
              CounterBox(
                counterServiceRM: counterServiceRM,
                seconds: 1,
                tag: 'blueCounter',
                color: Colors.blue,
              ),
              //NOTE2 : CounterBox widget. green counter with three seconds of waiting
              CounterBox(
                counterServiceRM: counterServiceRM,
                seconds: 3,
                tag: 'greenCounter',
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),

      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.lightBlue,
        ),
      ),
    );
  }
}
```
As the state management requires, we check if the reactive instance has an error and set the `primarySwatch` color to red [NOTE1].

`CounterBox` is a custom widget to display a box of a counter with customized color and time of waiting [NOTE2].


```dart
class CounterBox extends StatelessWidget {
  CounterBox({
    this.seconds,
    this.counterServiceRM,
    this.tag,
    this.color,
  });

  final int seconds;
  final ReactiveModel<CounterService> counterServiceRM;
  final String tag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          //NOTE1: Use of WhenRebuilder widget to subscribe to counterServiceRM reactive instance
           WhenRebuilder(
            models: [counterService],
            tag: tag,
            onIdle: () => Text('Top on the btn to increment the counter'),
            onWaiting: () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$seconds second(s) wait  '),
                CircularProgressIndicator(),
              ],
            ),
            onError: (error) => Text(
              counterService.error.message,
              style: TextStyle(color: Colors.red),
            ),
            onData: (data) => Text(
              ' ${counterService.state.counter.count}',
              style: TextStyle(fontSize: 30),
            ),
          ),
          IconButton(
            onPressed: () {
             //NOTE5: Trigger the increment event to mutate the state and notify listeners
              counterServiceRM.setState(
                (state) => state.increment(seconds),

                //NOTE5: Filter the notification with the tag.
                filterTags: [tag],


                //NOTE5: onError callback.
                onError: (BuildContext context, dynamic error) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(counterServiceRM.error.message),
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: color,
            ),
            iconSize: 40,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      // Decoration of the Container
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: color,
        ),
      ),
      margin: EdgeInsets.all(5),
    );
  }
}
```

For more explanation refer to [double_future_counter_with_error](https://github.com/GIfatahTH/states-rebuilder-examples/tree/master/002-double_future_counter_with_error).

This is the resultant GIF of what I called the polluted environment.


<image src="https://github.com/GIfatahTH/repo_images/blob/master/006-grid_counter_with_reactive_environnement_before.gif" width="300"/>

As you can see if any of the buttons of any counter is tapped, it will influence all other counters. Also, remark that the snackBar always appears in the last counter (fourth quarter).

To clean the reactive environment so that each counter works independently from other counters even if they share the same model, we will create new reactive environments.

## New reactive environments:

Let's refactor the code to use new reactive environments :

```dart
class CounterGridPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject(
          () => CounterService(),
          //NOTE1 Specifying how reactive singleton and new reactive instances are joined.
          joinSingleton: JoinSingleton.withCombinedReactiveInstances,
        )
      ],
      builder: (BuildContext context) {
        //NOTE2 : Get the registered reactive singleton. 
        final counterServiceSingleton =
            Injector.getAsReactive<CounterService>();

        return Scaffold(
          appBar: AppBar(
            //NOTE3: This is the application AppBar
            //NOTE3: The title of the appBar is reactive and for each state of the reactive singleton it will display the corresponding widget.

            title: WhenRebuilder(
              models: [counterServiceSingletonRM],
              //NOTE3: tag to be used to filter notification
              tag: 'appBar',
              onIdle: () => Text('There are still counters waiting for you'),
              onWaiting: () => Row(
                children: <Widget>[
                  //NOTE4: new reactive instances can send data to the reactive singleton 
                  //NOTE4: sent data is held in the joinSingletonToNewData field.
                  Text('${counterServiceSingletonRM.joinSingletonToNewData}  '),
                  CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              onError: (error) => Text(
                'Some counters have ERROR',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onData: (data) => Text('All counters have data'),
          ),
          body: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            children: <Widget>[
              //NOTE5: Creating a new reactive instance using StateBuilder with generic type and without models parameter.
              StateBuilder<CounterService>(
                builder: (context, counterServiceRM) {
                  return CounterApp(
                    counterServiceRM: counterServiceRM,
                    name: 'Counter 1',
                  );
                },
              ),
              //NOTE5: new reactive instance for counter2
              StateBuilder<CounterService>(
                builder: (context, counterServiceRM) {
                  return CounterApp(
                    counterServiceRM: counterServiceRM,
                    name: 'Counter 2',
                  );
                },
              ),
              //NOTE5: new reactive instance for counter3
              StateBuilder<CounterService>(
                builder: (context, counterServiceRM) {
                  return CounterApp(
                    counterServiceRM: counterServiceRM,
                    name: 'Counter 3',
                  );
                },
              ),
              //NOTE5: new reactive instance for counter4
              StateBuilder<CounterService>(
                builder: (context, counterServiceRM) {
                  return CounterApp(
                    counterServiceRM: counterServiceRM,
                    name: 'Counter 4',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
```

Take not that states_rebuilder, for each injected model, it registers two singletons:
* Row singleton of the model: Which is the cached instance of the model. To get it, we use `Injector.get` method;
* The reactive singleton of the model: which is the raw singleton decorated which reactive environment. To get it, we use `Injector.getAsReactive` method.[NOTE2]

With states_rebuilder, you can create as many new reactive environments as you want:

>New reactive instance is the same raw singleton but decorated with a new reactive environment:

We use `StateBuilder` with generic type and without `models` parameter to created new reactive environments [NOTE5].

Although reactive singleton and new reactive instances have totally independent reactive environments, they can share data and communicate state between them.

> We say that we are joining reactive singleton with new reactive instance:

There are two modes of joining : 
* `JoinSingleton.withCombinedReactiveInstances` [NOTE1]
* `JoinSingleton.withNewReactiveInstance`

See the readme file of the states_rebuilder for more details.

To fulfill the state management requirement of our example, we choose  `JoinSingleton.withCombinedReactiveInstances`  because we want new reactive instances to share with the reactive singleton a combined state.

That is :
* If any of the new reactive instances are waiting than the reactive singleton is waiting
* If any of the new reactive instances has error than the reactive singleton has an error with the error throw by the new reactive instance that has sent the notification.
* If any of the new reactive instances is none than the reactive singleton is none.
* If and only if all new reactive instance has data than the reactive singleton has data.

New reactive instances can send custom information to reactive singleton the time of sending a notification using `joinSingletonToNewData` [NITE4].


Making a profit of the ability of the new reactive instance to share their state, send custom data and sent notifications to the reactive singleton we set the `AppBar` of the application to be reactive and display what is demanded from the state management requirements.

Let's continue with the `CounterApp` widget:

```dart
class CounterApp extends StatelessWidget {
  const CounterApp({Key key, this.counterServiceRM, this.name}) : super(key: key);
  final ReactiveModel<CounterService> counterServiceRM;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      //NOTE1: Changing the primarySwatch color to red if there is an error.
      child: StateBuilder(
        models: [counterServiceRM],
        //NOTE1 : Using the tag to notify this StateBuilder when an error happens
        tag: 'appBar',
        builderWithChild: (context, snapshot, child) {
          return Theme(
            data: ThemeData(
              primarySwatch:
                  counterServiceRM.hasError ? Colors.red : Colors.lightBlue,
            ),
            child: child,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(name),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CounterBox(
                counterServiceRM: counterServiceRM,
                seconds: 1,
                tag: 'blueCounter',
                color: Colors.blue,
                name: name,
              ),
              CounterBox(
                counterServiceRM: counterServiceRM,
                seconds: 3,
                tag: 'greenCounter',
                color: Colors.green,
                name: name,
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.lightBlue,
        ),
      ),
    );
  }
}
```

We use `StateBuilder` with the `appBar` tag to control its rebuild.

>With states_rebuilder whenever you want to have finer controller over when and where to send a notification use `StateBuilder` widget.

The `CounterBox` widget is : 

```dart

class CounterBox extends StatelessWidget {
  CounterBox({
    this.seconds,
    this.counterServiceRM,
    this.tag,
    this.color,
    this.name,
  });
  final int seconds;
  final ReactiveModel<CounterService> counterServiceRM;
  final String tag;
  final Color color;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          WhenRebuilder(
            models: [counterService],
            tag: tag,
            onIdle: () => Text('Top on the btn to increment the counter'),
            onWaiting: () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$seconds second(s) wait  '),
                CircularProgressIndicator(),
              ],
            ),
            onError: (error) => Text(
              counterService.error.message,
              style: TextStyle(color: Colors.red),
            ),
            onData: (data) => Text(
              ' ${counterService.state.counter.count}',
              style: TextStyle(fontSize: 30),
            ),
          ),
          IconButton(
            onPressed: () {
              counterServiceRM.setState(
                (state) => state.increment(seconds),
                //NOTE1: Notify StateBuilder widget with these tags.
                filterTags: [tag, 'appBar'],
                //NOTE2 : Send custom data to reactive singleton
                joinSingletonToNewData: name,
                onError: (BuildContext context, dynamic error) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(counterServiceRM.error.message),
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: color,
            ),
            iconSize: 40,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      // Decoration of the Container
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: color,
        ),
      ),
      margin: EdgeInsets.all(5),
    );
  }
}
```

The `CounterBox` is similar to that of the polluted example, the only differences are: 
* `stateState` nonfiction is filleted. So after calling the `increment` method of the reactive instance and if a notification is sent only widgets that have tags of (`blueCounter` or `blueCounter`) and `appBar` will be notified to rebuild [NOTE1].
* In the `onSetState` method we set the field `joinSingletonToNewData` to hold the name of the counter. This name is sent to the reactive singleton to identify the counter that has been tapped.

This is an example of the chronology of state nonfiction:

1. You tap on the `blueCounter` to increment the counter app of the first counter (the first quarter).

2. The method :
```dart
counterServiceRM.setState(
   (state) => state.increment(seconds),
   filterTags: [tag, 'appBar'],
   ...
)
```
is called on the new reactive instance `counterServiceRM` of first counter.
   
3. Because `increment` is asynchronous method, the reactive `connectionState` is set to `waiting` and notification is sent to the widgets with tags `blueCounter` and `appBar` that are subscribed to the counter one new reactive instance `counterServiceRM`. The other new reactive instance of the second, third and fourth counter will not be affected.   

4. Because we set `joinSingleton` to `JoinSingleton.withCombinedReactiveInstances`, the `connectionState` of the reactive singleton is set to `waiting` and notification is sent to the widgets with tags `blueCounter` and `appBar` that are subscribed to the reactive singleton.    

5. Before rebuilding listening widgets, `onSetState` is called and it execute the `onError` callback. We set `joinSingletonToNewData` parameter to hold the name of the counter which is 'counter 1'. This name is send to the reactive singleton.
After we check if the first counter reactive instance has an error and display a snackBar.   

6. Now listening widgets will rebuild to reproduce the new state. The first counter will display a `CircularProgressIndicator ` from this code:
```dart
onWaiting: ()=> Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    Text('$seconds second(s) wait  '),
    CircularProgressIndicator(),
    ],
)

```
and the application AppBar will display the String 'counter 1' followed by a `CircularProgressIndicator`. The the String 'counter 1' is hold in the field `joinSingletonToNewData` of the reactive singleton : 
```dart
onWaiting: ()=>  Row(
    children: <Widget>[
        Text(
            '${counterServiceSingleton.joinSingletonToNewData}  '),
        CircularProgressIndicator(
        backgroundColor: Colors.white,
        ),
    ],
    )
```

7. After the `increment` method completes, it completes with error the `hasError` of the first counter reactive instance is set to true and notification is sent to listeners with the defined filter tag list.
8. Because we set `joinSingleton` to `JoinSingleton.withCombinedReactiveInstances`, the `hasError` of the reactive singleton is set to true and notification is sent to listeners with the defined filter tag list.
9. before rebuild `onSetState` is executed and a snackBar with the error is displayed in the context of the first counter.

and so on ... 
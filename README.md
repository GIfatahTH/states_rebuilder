# states_rebuilder

A Flutter state management solution that allows you: 
  * to separate your User Interface (UI) representation from your logic classes
  * to easily control how your widgets rebuild to reflect the actual state of your application. 

This Library provides two classes and one method:

  * The `StatesRebuilder` class. Your logics classes will extend this class to create your own business logic BloC (equally can be called ViewModel or Model).
  * The `rebuildStates` method. You call it inside any of your logic classes that extends `StatesRebuilder`. It offers you two ways to rebuild any of your widgets.
  this is the signature of the `rebuildState`:
  ```dart
  rebuildStates([List<dynamic> states])
  ```
  * The `StateBuilder` Widget. You wrap any part of your widgets with it to make it available inside your logic classes and hence can rebuild it using `rebuildState` method
  this is the constructor of the `StateBuilder`:
  ```dart
  StateBuilder( {
      Key key, 
      dynamic stateID, // you define the ID of the state. This is the first way
      List<StatesRebuilder> blocs, // You give a list of the logic classes (BloC) you want this ID will be available.
      @required (State) → Widget builder,  // You define your top most Widget.
      (State) → void initState, // for code to be executed in the initState of a StatefulWidget
      (State) → void dispose, // for code to be executed in the dispose of a StatefulWidget
      (State) → void didChangeDependencies, // for code to be executed in the didChangeDependencies of a StatefulWidget
      (StateBuilder, State) → void didUpdateWidget // for code to be executed in the didUpdateWidget of a StatefulWidget
      bool withTickerProvider: false // set to true if you want your state class to mix with `TickerProviderStateMixin`. Default value is false.
    });
  ```
  `stateID` is of type dynmaic. It can be String (for small projects) or enum member (enums are preferred for big projects).

  For the first way you have to provide the stateID and blocs parameters. Whereas for the second way you have not. See prototype example bellow.
	
  * `BlocProvider` widget. Used to provide your BloCs
  ```dart
   BlocProvider<YourBloc>({
     CounterBloc bloc
     Widget child,
   })
  ```
## Prototype Example

your_bloc.dart file:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:states_rebuilder/states_rebuilder.dart'

  // enum is preferred over String to name your `stateID` for big projects.
  // The nume of the enum is of your choice. You can have many enums.

  // -- Conventionally for each of your BloCs you define a corresponding enum.
  // -- For very large projects you can make all your enums in a single file.
  enum YourState {yourStateID1};

  class YourBloc extends StatesRebuilder{

      var yourVar;

      /// You have two ways:

      /// ************** First way: (ID way) **************

      yourMethod1() {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([YourState.yourStateID1]);
      }

      // example of fetching data and rebuilding widgets after obtaining the data
      fetchData1() async {
        await yourRepository.fetchDate();
        rebuildStates([YourState.yourStateID1]);
      }

      /// ************** Second way (state way) **************

      yourMethod2(State state) {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([state]);
      }

      // example of fetching data and rebuild widgets after obtaining the data
      fetchData2(State state) async {
        await yourRepository.fetchDate();
        rebuildStates([state]);
      }

      /// ************** Combination of first and second ways **************

      yourMethod3(State state) {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([state, YourState.yourStateID1]);
      }


      /// ************** Rebuild All **************
      yourMethod4() {
        // some logic staff;
        yourVar = yourNewValue;


         // `rebuildStates()` with no parameter: All widgets that are wrapped with
         //`StateBuilder` and are given `stateID` will rebuild to reflect the new counter value.
         // You get a similar behavior like in ``scoped_model`` or ``provider`` packages

        rebuildStates();
      }
  }
  ```
your main.dart file:

```dart
  // ************** First way: (ID way) ************** 
  class Firstway extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Column(
            children: <Widget> [
              StateBuilder(
                stateID : YourState.yourStateID1 // you can use just a String "yourStateID1",
                blocs : [yourBloc],
                initState: (_)=> yourBloc.fetchData1(),
                builder: (_) => YourChildWidget(yourBloc.yourVar),
            ),
            RaisedButton(
              child: Text("first way"),
              onPressed : yourBloc.yourMethod1,
            )
          ],
      );
    }
  }

    // ************** Second way: (ID way) ************** 
    class Secondway extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return StateBuilder(
              initState: yourBloc.fetchData2,
              builder: (State state) => Column(
                    children: <Widget> [
                      YourChildWidget(yourBloc.yourVar),
                      RaisedButton(
                        child: Text("Second way"),
                        onPressed :yourBloc.yourMethod2(state),
                      ), 
                    ],
                  ),
              );
    }
  }
```

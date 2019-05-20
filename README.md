# states_rebuilder

A Flutter state management solution that allows you: 
  * to separate your User Interface (UI) representation from your logic classes
  * to easily control how your widgets rebuild to reflect the actual state of your application. 

This Library provides two classes and one method:

  * The `StatesRebuilder` class. Your logics classes will extend this class to create your own business logic BloC (equally can be called ViewModel or Model).
  * The `rebuildStates` method. You call it inside any of your logic classes that extends `StatesRebuilder`. It rebuilds all the mounted 'StateBuilder' widgets. It can all flitre the widgets to rebuild by tag.
  this is the signature of the `rebuildState`:
  ```dart
  rebuildStates([List<dynamic> tags])
  ```
  * The `StateBuilder` Widget. You wrap any part of your widgets with it to make it available inside your logic classes and hence can rebuild it using `rebuildState` method
  this is the constructor of the `StateBuilder`:
  
  ```dart
  StateBuilder( {
      Key key, 
      dynamic tag, // you define the tag of the state. This is the first way
      List<StatesRebuilder> blocs, // You give a list of the logic classes (BloC) you want this widget to listen to.
      @required (BuildContext, String) → Widget builder,  // .
      (StateBuilder, String) → void initState, // for code to be executed in the initState of a StatefulWidget
      (StateBuilder, String) → void dispose, // for code to be executed in the dispose of a StatefulWidget
      (StateBuilder, String) → void didChangeDependencies, // for code to be executed in the didChangeDependencies of a StatefulWidget
      (StateBuilder, String, StateBuilder) → void didUpdateWidget // for code to be executed in the didUpdateWidget of a StatefulWidget
    });
  ```
  `tag` is of type dynmaic. It can be String (for small projects) or enum member (enums are preferred for big projects).

  To extands the state with mixin (practical case with animation), use `StateWithMixinBuilder`

    ```dart
  StateWithMixinBuilder( {
      Key key, 
      dynamic tag, // you define the tag of the state. This is the first way
      List<StatesRebuilder> blocs, // You give a list of the logic classes (BloC) you want this this widget to listen to.
      @required (BuildContext, String) → Widget builder,  // You define your top most Widget.
      @required (BuildContext, String,T) → void initState, // for code to be executed in the initState of a StatefulWidget
      @required (BuildContext, String,T) → void dispose, // for code to be executed in the dispose of a StatefulWidget
      (BuildContext, String,T) → void didChangeDependencies, // for code to be executed in the didChangeDependencies of a StatefulWidget
      (BuildContext, String,StateBuilder, T) → void didUpdateWidget // for code to be executed in the didUpdateWidget of a StatefulWidget,
      (String, AppLifecycleState) → void didChangeAppLifecycleState // 
      @required MixinWith mixinWith
    });
  ```
    Avaibable mixins are: singleTickerProviderStateMixin, tickerProviderStateMixin, AutomaticKeepAliveClientMixin and WidgetsBindingObserver.

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

  // enum is preferred over String to name your `tag` for big projects.
  // The nume of the enum is of your choice. You can have many enums.

  // -- Conventionally for each of your BloCs you define a corresponding enum.
  // -- For very large projects you can make all your enums in a single file.
  enum YourState {yourtag1};

  class YourBloc extends StatesRebuilder{

      var yourVar;

      /// You have two ways:

      /// ************** First way: (tag way) **************

      yourMethod1() {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([YourState.yourtag1]);
      }

      // example of fetching data and rebuilding widgets after obtaining the data
      fetchData1() async {
        await yourRepository.fetchDate();
        rebuildStates([YourState.yourtag1]);
      }

      /// ************** Second way (tag way) **************

      yourMethod2(String tagID) {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([tagID]);
      }

      // example of fetching data and rebuild widgets after obtaining the data
      fetchData2(String tagID) async {
        await yourRepository.fetchDate();
        rebuildStates([tagID]);
      }

      /// ************** Combination of first and second ways **************

      yourMethod3(String tagID) {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([tagID, YourState.yourtag1]);
      }


      /// ************** Rebuild All **************
      yourMethod4() {
        // some logic staff;
        yourVar = yourNewValue;


         // `rebuildStates()` with no parameter: All widgets that are wrapped with
         //`StateBuilder` will rebuild to reflect the new counter value.
         // You get a similar behavior like in ``scoped_model`` or ``provider`` packages

        rebuildStates();
      }
  }
  ```
your main.dart file:

```dart
  // ************** First way: (tag way) ************** 
  class Firstway extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Column(
            children: <Widget> [
              StateBuilder(
                tag : YourState.yourtag1 // you can use just a String "yourtag1",
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

    // ************** Second way: (tag way) ************** 
    class Secondway extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return StateBuilder(
              initState: yourBloc.fetchData2,
              builder: (String tagID) => Column(
                    children: <Widget> [
                      YourChildWidget(yourBloc.yourVar),
                      RaisedButton(
                        child: Text("Second way"),
                        onPressed :yourBloc.yourMethod2(tagID),
                      ), 
                    ],
                  ),
              );
    }
  }
```

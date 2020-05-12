///Assertions
class AssertMessage {
//   /// getModelNotStatesRebuilderWithContext
//   static String getModelNotStatesRebuilderWithContext<T>() {
//     return '''

// | ***[$T] is not a StatesRebuilder***
// | You are using the BuildContext to subscribe to a widget to a model that is not reactive.
// |
// | To fix, you have to either:
// | - Remove the context parameter, if [$T] is not reactive.
// | - Extend 'StatesRebuilder'.
// | - Use 'Injector.getAsReactive' instead of 'Injector.get'
// |
//         ''';
//   }

//   ///getModelWithContextAndName
//   static String getModelWithContextAndName<T>(String injectorGet, String name) {
//     return '''
// | ***get model with both name and BuildContext***
// | You are using the BuildContext to subscribe a widget to a model registered with custom name.
// | This is not allowed, because getting model with BuildContext relies on InheritedWidget which use type rather than custom name to get the model.
// |
// | To fix, use '$injectorGet' without context and use 'StateBuilder' widget for subscription.
// |   ex:
// |   final model = $injectorGet<${T == dynamic ? 'T' : T}>(name: $name);
// |
// |   return StateBuilder(
// |     models: [model]
// |     builder: (context,model){
// |       ....
// |     }
// |   )
// |
//         ''';
//   }

//   ///inheritedWidgetOfReturnsNull
//   static String inheritedWidgetOfReturnsNull<T>(String injectorGet) {
//     return '''
// | ***No InheritedWidget of type [$T] is found***
// | You are using the BuildContext to subscribe the widget to [$T] model.
// | This subscription happens by looking up the widget tree to find the nearest InheritedWidget of type [$T].
// |
// | [$T] is registered in the service locator but not found by the BuildContext, and this most probably happens after page navigation.
// |
// | To fix you have to either:
// | 1- Check that the BuildContext is of a child widget of the Injector widget where the model $T is injected.
// |
// | 2- Use '$injectorGet' without context and use 'StateBuilder' widget for subscription.
// |   ex:
// |   final model = $injectorGet<${T == dynamic ? 'T' : T}>();
// |
// |   return StateBuilder(
// |     models: [model]
// |     builder: (context,model){
// |       ....
// |     }
// |   )
// |
// | 3- Reinject the model before navigation:
// |   ex:
// |       Navigator.push(
// |         context,
// |         MaterialPageRoute(
// |           builder: (context) => Injector(
// |             reinject: [${T}_Instance],
// |             builder: (context) {
// |               return NewPage();
// |             },
// |           ),
// |         ),
// |       );
// |
//         ''';
//   }

  ///modelNotRegistered
  static String modelNotRegistered(String name, String keys) {
    return '''|

***The model [$name] is not registered yet***
| You have to register the model before calling it.
| 
| To register the model use the `Injector` widget.
| You can set the silent parameter to true to silent the error.
| 
| This is the list of registered models: $keys.
|''';
  }

//   ///reinjectNonInjectedInstance
//   static String reinjectNonInjectedInstance<T>(String reinject) {
//     return '''

// | ***Reinjecting non registered instance***
// | You are trying to rienject an instance of $reinject
// | that is not registered. You can only rienject already registered models.
//       ''';
//   }

//   ///getNewReactiveInstanceWithContext
//   static String reinjectModelNotFound<T>(String reinject) {
//     return '''

// | ***Reinjected model not founded***
// | The model $reinject you reinject is not found.
// | It is most probably that you have registered the model with a custom name.
// |
// | Rinjection of registered models with custom names is not allowed.
// |
//               ''';
//   }

  static String gettingAsReactiveAStatesRebuilderModel(String s) {
    return '''

| ***Getting a StatesRebuilder model using getAsReactive method***
| You are trying to get the model "$s" which is of type StatesRebuilder.
|
| This is not allowed please use 'Injector.get' instead
|
              ''';
  }

//   static String reinjectingNewReactiveInstance(String reinject) {
//     return '''
// | ***Reinjecting new reactive instance***
// | You are reinjecting a new reactive instance of [$reinject].
// | New reactive instance can not be reinject, only reactive singleton that can be reinjected.
// |
// | To use subscribe to new reactive instance use StateBuilder widget.
// |
// |   ex:
// |   final model = Injector.getAsReactive<$reinject]>(asNewReactiveInstance: true);
// |
// |   return StateBuilder(
// |     models: [model],
// |     builder:(context,model){
// |       ....
// |     }
// |   );
//         ''';
//   }

  static String noModelsAndDynamicType() {
    return '''
      
***No model is defined***
You are using [StateBuilder] widget without providing a generic type or defining the [models] parameter.

To fix, you have to either :
1- Provide a generic type to create and subscribe to a new reactive environment
  ex:
    StateBuilder<MyModel>(
      Builder:(BuildContext context, ReactiveModel<MyModel> myModel){
        return ...
      }
    )
2- define the [models] property. to subscribe to an already defined reactive environnement instance
  ex:
    StateBuilder(
      models : [myModelInstance],
      Builder:(BuildContext context, ReactiveModel<MyModel> myModel){
        return ...
      }
    )
      ''';
  }

  static String setStateCalledOnAsyncInjectedModel() {
    return '''

Most probably, you are calling setState on a reactive model injected using `Inject.stream` or `Inject.future`.
This is not allowed, because setState method of a reactive model injected using `Inject.stream` or `Inject.future` is called automatically whenever the stream emits a value.

            ''';
  }

//   static injectingAnInjectedModel(String name) {
//     return '''
// ***Injecting an already injected model***
// You are injecting the [$name] model which is already injected.
// This is not allowed.
// If we are sure you want to inject it again, try injecting it with custom name.

// If you are testing the widget set [Injector.enableTestMode] to true
//     ''';
//   }
}

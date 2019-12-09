class AssertMessage {
  static String getInjectStreamAndFutureError() {
    return '''

| ***Inject.stream and Inject.future***
| Getting injected stream and future is not allowed.
| 
| To fix, you have to use 'Injector.getAsReactive' instead of 'Injector.get' 
|
      ''';
  }

  static String getModelNotStatesRebuilderWithContext<T>() {
    return '''

| ***[$T] is not a StatesRebuilder***
| You are using the BuildContext to subscribe a widget to a model that is not reactive.
| 
| To fix, you have to either:
| - Remove the context parameter, if [$T] is not reactive.
| - Extend 'StatesRebuilder'.
| - Use 'Injector.getAsReactive' instead of 'Injector.get' 
| 
        ''';
  }

  static String getModelWithContextAndName<T>(String injectorGet, String name) {
    return '''
| ***get model with both name and BuildContext***
| You are using the BuildContext to subscribe a widget to a model registered with custom name.
| This is not allowed, because getting model with BuildContext relies on InheritedWidget which use type rather than custom name to get the model.
|
| To fix, use '$injectorGet' without context and use 'StateBuilder' widget for subscription.
|   ex:
|   final model = $injectorGet<${T == dynamic ? 'T' : T}>(name: $name);
|
|   return StateBuilder(
|     models: [model]
|     builder: (context,model){
|       ....
|     }
|   )
|
        ''';
  }

  static String inheritedWidgetOfReturnsNull<T>(String injectorGet) {
    return '''
| ***No InheritedWidget of type [$T] is found***
| You are using the BuildContext to subscribe the widget to [$T] model.
| This subscription happens by looking up the widget tree to find the nearest InheritedWidget of type [$T].
| 
| [$T] is registered in the service locator but not found by the BuildContext, and this most probably happens after page navigation. 
| 
| To fix you have to either:
| 1- Check that the BuildContext is of a child widget of the Injector widget where the model $T is injected.
| 
| 2- Use '$injectorGet' without context and use 'StateBuilder' widget for subscription.
|   ex:
|   final model = $injectorGet<${T == dynamic ? 'T' : T}>();
|
|   return StateBuilder(
|     models: [model]
|     builder: (context,model){
|       ....
|     }
|   )
| 
| 3- Reinject the model before navigation:
|   ex:
|       Navigator.push(
|         context,
|         MaterialPageRoute(
|           builder: (context) => Injector(
|             reinject: [${T}_Instance],
|             builder: (context) {
|               return NewPage();
|             },
|           ),
|         ),
|       );
| 
        ''';
  }

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

  static String getNewReactiveInstanceWithContext<T>() {
    return '''

| ***Getting new reactive instance with context***
| You are using 'Injector.getAsReactive' to get a new reactive instance with the context parameter defined.
| This is not allowed because the context parameter is use to subscribe the widget to the reactive singleton and not the the new one.
| 
| To fix, remove the context parameter and use 'StateBuilder' for subscription.
| 
|   ex:
|   final model = Injector.getAsReactive<$T>(asNewReactiveInstance: true);
| 
|   return StateBuilder(
|     models: [model],
|     builder:(context,model){
|       ....
|     }
|   );
| 
      ''';
  }
}

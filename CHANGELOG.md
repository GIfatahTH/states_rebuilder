## 1.6.0+1
* Add `Injector.getAsModel` method. When called with the context parameter, the calling widget is automatically registered as a listener.
* Add `setState(Function(state))` to mutate the state and update the dependent the views from the UI.
* Model class have not to extend `StatesRebuilder` to get reactivity.
* Add the named constructor`Inject.future` which take a future and update dependents when future completes.
* Add the named constructor`Inject.stream` which take a steam and update dependents when stream emits a value.
* `Injector.get` or `Injector.getAsModel` now throws if no registered model is found. This can be silent by setting the parameter `silent` to true
* Injected model ara lazily instantiated. To do otherwise set the parameter `isLazy` of the `Inject` widget to false.


## 1.5.1
* add `afterInitialBuild` and `afterRebuild` parameters to the `StateBuilder`, `StateWithMixinBuilder` and `Injector` widgets.`
  `afterInitialBuild` and `afterRebuild` are callBack to be executed after the widget is mounted and after each rebuild. 

## 1.5.0+1
* Use `ObservableService` and `hasState` instead of `Observable` and `hasObserver`, because the latters are widely used and can lead to conflict


## 1.5.0
* Add `hasStates` getter to check if the StatesRebuilder object has listener.
* Add `inject` parameter to the `Injector` widget as an alternative to the `models` parameter. With `inject` you can register models using interface Type. 
* Add `observable` interface. Any service class can implement it to notify any ViewModel to rebuild its corresponding view.
* Refactor the library to make it design patterns wise and hence make it testable.
* Test the library

## 1.3.2
* Add `appLifeCycle` argument to Injector to track the life cycle of the app.
* Refactor the code.


## 1.3.1
* remove `rebuildFromStreams`.
* Initial release of `Streaming` class
* The builder closure of the `Injector` takes (BuildContext context, T model) where T is the generic type.
* Fix typos

## 1.3.0
* Initial release of `rebuildFromStreams` method.
* Initial release of `Injector` for Dependency Injection.
* deprecate blocs parameter and use viewModels instead
* StateBuilder can have many tags.

## 1.2.0
 *  Remove `stateID` and replace it by `tag` parameter. `tag` is optional and many widgets can have the same tag.
 *  `rebuildStates()` when called without parameters, it rebuilds all widgets that are wrapped with `StateBuilder` and `StateWithMixinBuilder`.
 *  Each `StateBuilder` has an automatically generated cached address. It is stored in the second parameter of the `builder`, `initState`, `dispose`,  and other closures. You can call it inside the closures to rebuild that particular widget.
 *  add `StateWithMixinBuilder` widget to account for some of the most used mixins.
 *  Optimize the code and improve performance

## 1.1.0
 * Add `withTickerProvider` parameter to `StateBuilder` widget.


## 1.0.0
 * Add `BlocProvider`to provide your BloCs.
 * You can use enums to name your `StateBuilder` widgets.
 * `rebuildStates` now has only one positioned parameter of List<dynamic>.
 * If `rebuildStates` is given without parameter, it will rebuild all widgets that have `stateID`.
 * improve performance.


## 0.1.4

  * improve performance


## 0.1.3

  * Add getter and setter for the stateMap.

## 0.1.2

  * Remove print statements

## 0.1.1

  * Change readme.md of the example

## 0.1.0

  * Initial version

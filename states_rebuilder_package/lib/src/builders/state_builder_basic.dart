part of '../builders.dart';

// /// One of the four observer widgets in states_rebuilder
// ///
// /// [WhenRebuilder], [WhenRebuilderOr] and [OnSetStateListener]
// ///
// class StateBuilderBasic<T> extends StatefulWidget {
//   ///```dart
//   ///StateBuilder(
//   ///  models:[myModel],
//   ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
//   ///)
//   ///```
//   ///The build strategy currently used to rebuild the state.
//   ///
//   ///The builder is provided with a [BuildContext] and [ReactiveModel] parameters.
//   final Widget Function(BuildContext context, ReactiveModel<T> model) builder;

//   ///an observable class to which you want [StateBuilder] to subscribe.
//   ///```dart
//   ///StateBuilder(
//   ///  observe:()=> myModel1,
//   ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
//   ///)
//   ///```
//   ///states_rebuilder uses the observer pattern.
//   ///
//   ///Observable classes are classes that extends [StatesRebuilder].
//   ///[ReactiveModel] is one of them.
//   final StatesRebuilder<T> Function() observe;

//   ///List of observable classes to which you want [StateBuilder] to subscribe.
//   ///```dart
//   ///StateBuilder(
//   ///  observeMany:[()=> myModel1,()=> myModel2,()=> myModel3],
//   ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
//   ///)
//   ///```
//   ///states_rebuilder uses the observer pattern.
//   ///
//   ///Observable classes are classes that extends [StatesRebuilder].
//   ///[ReactiveModel] is one of them.
//   final List<StatesRebuilder Function()> observeMany;

//   ///A tag or list of tags you want this [StateBuilder] to register with.
//   ///
//   ///Whenever any of the observable model to which this [StateBuilder] is subscribed emits
//   ///a notifications with a list of filter tags, this [StateBuilder] will rebuild if the
//   ///the filter tags list contains at least on of those tags.
//   ///
//   ///It can be String (for small projects) or enum member (enums are preferred for big projects).
//   ///
//   ///Each [StateBuilder] has a default tag which is its [BuildContext]
//   final dynamic tag;

//   ///```dart
//   ///StateBuilder(
//   ///  initState:(BuildContext context, ReactiveModel model)=> myModel.init([context,model]),
//   ///  models:[myModel],
//   ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
//   ///)
//   ///```
//   ///Called when this object is inserted into the tree.
//   final void Function(BuildContext context, ReactiveModel<T> model) initState;

//   ///```dart
//   ///StateBuilder(
//   ///  dispose:(BuildContext context, ReactiveModel model) {
//   ///     myModel.dispose([context, model]);
//   ///   },
//   ///  models:[myModel],
//   ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
//   ///)
//   ///```
//   ///Called when this object is removed from the tree permanently.
//   final void Function(BuildContext context, ReactiveModel<T> model) dispose;

//   ///if it is set to true all observable models will be disposed.
//   ///
//   ///Models are disposed by calling the 'dispose()' method if exists.
//   ///
//   ///In any of the injected class you can define a 'dispose()' method to clean up resources.
//   final bool disposeModels;

//   ///```dart
//   ///StateBuilder(
//   ///  models:[myModel],
//   ///  builderWithChild:(BuildContext context, ReactiveModel model, Widget child) =>MyWidget(child),
//   ///  child : MyChildWidget(),
//   ///)
//   ///```
//   ///The build strategy currently used to rebuild the state with child parameter.
//   ///
//   ///The builder is provided with a [BuildContext], [ReactiveModel] and [Widget] parameters.
//   final Widget Function(
//           BuildContext context, ReactiveModel<T> model, Widget child)
//       builderWithChild;

//   ///The child to be used in [builderWithChild].
//   final Widget child;

//   ///Called whenever this widget is notified.
//   final dynamic Function(BuildContext context, ReactiveModel<T> model)
//       onSetState;

//   /// callback to be executed before notifying listeners. It the returned value is
//   /// the same as the last one, the rebuild process is interrupted.
//   ///
//   final Object Function(ReactiveModel<T> model) watch;

//   ///Callback to determine whether this StateBuilder will rebuild or not.
//   ///
//   final bool Function(ReactiveModel<T> model) shouldRebuild;

//   ///ReactiveModel key used to control this widget from outside its [builder] method.
//   final RMKey rmKey;

//   /// One of the four observer widgets in states_rebuilder
//   ///
//   /// [WhenRebuilder], [WhenRebuilderOr] and [OnSetStateListener]
//   StateBuilderBasic({
//     Key key,
//     // For state management
//     this.builder,
//     this.builderWithChild,
//     this.child,
//     //
//     this.observe,
//     this.observeMany,
//     this.tag,
//     this.onSetState,
//     this.watch,
//     this.shouldRebuild,
//     //
//     this.rmKey,
//     // For state lifecycle
//     this.initState,
//     this.dispose,
//     this.disposeModels,
//   })  : assert(builder != null || builderWithChild != null, '''

//   | ***Builder not defined***
//   | You have to define either 'builder' or 'builderWithChild' parameter.
//   | Use 'builderWithChild' with 'child' parameter.
//   | If 'child' is null use 'builder' instead.

//         '''),
//         assert(builderWithChild == null || child != null, '''
//   | ***child is null***
//   | You have defined the 'builderWithChild' parameter without defining the child parameter.
//   | Use 'builderWithChild' with 'child' parameter.
//   | If 'child' is null use 'builder' instead.

//         '''),
//         super(key: key);

//   @override
//   State<StateBuilderBasic<T>> createState() {
//     return StateBasic<T>();
//     // if (observeMany == null && observe != null) {
//     // }
//     // return StateBuilderState<T>();
//   }
// }

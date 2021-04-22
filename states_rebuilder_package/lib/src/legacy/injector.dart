import 'package:flutter/material.dart';

import '../rm.dart';

// import 'assertions.dart';
import 'inject.dart';

///A widget used to provide a business logic model to the widget tree,
///and make one instance of the model available to all its children.
///
///```dart
/// //Your pure dare model
/// class Foo {}
///
/// //Your user interface
/// class App extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Injector(
///       inject: [Inject(() => Foo())],
///       builder: (BuildContext context) {
///         return ChildWidgetTree();
///       },
///     );
///   }
/// }
/// ```
///
///
/// With `Injector` you can inject multiple dependent or independent models (BloCs, Services) at the same time. Also you can inject stream and future.
///```dart
///Injector(
///  inject: [
///    //The order is not mandatory even for dependent models.
///    Inject<ModelA>(() => ModelA()),
///    Inject(() => ModelB()),//Generic type in inferred.
///    Inject(() => ModelC(Injector.get<ModelA>())),// Directly inject ModelA in ModelC constructor
///    Inject(() => ModelC(Injector.get())),// Type in inferred.
///    Inject<IModelD>(() => ModelD()),// Register with Interface type.
///    Inject<IModelE>({ //Inject through interface with environment flavor.
///      'prod': ()=>ModelImplA(),
///      'test': ()=>ModelImplB(),
///    }), // you have to set the `Inject.env = 'prod'` before `runApp` method
///    //You can inject streams and future and make them accessible to all the widget tree.
///    Inject<bool>.future(() => Future(), initialValue:0),// Register a future.
///    Inject<int>.stream(() => Stream()),// Register a stream.
///    Inject(() => ModelD(),name:"customName"), // Use custom name
///
///    //Inject and reinject with previous value provided.
///    Inject<ModelA>.previous((ModelA previous){
///      return ModelA(id: previous.id);
///    })
///  ],
///  builder: (BuildContext context) {
///         return ChildWidgetTree();
///   },
///);
///```
///
///Models are registered lazily by default. That is, they will not be instantiated until they are first used. To instantiate a particular model at the time of registration, you can set the `isLazy` variable of the class `Inject` to false.
///
///To consume any of the above injected model you can use :
///```dart
///IN.get<Foo>(); // to get the injected instance (equivalent to Injector.get<Foo>())
///RM.get<Foo>(); // to get the injected instance decorated with ReactiveModel  (equivalent to Injector.getAsReactive<Foo>())
///```
///You can injected asynchronously dependent object
///
///```dart
///Injector(
///    inject: [
///        //Inject the first future
///        Inject<FutureA>.future(() => futureA()),
///        //Inject the second future that depends on the first future
///        Inject<FutureB>.future(
///          () async => futureB(await RM.get<FutureA>().stateAsync),
///        ),
///        //Inject the third future that depends on the second future
///        Inject<FutureC>.future(
///          () async => futureC(await RM.get<FutureB>().stateAsync),
///        ),
///    ],
///    builder: (context) {
///        return WhenRebuilderOr(
///        observe: () => RM.get<FutureC>(),
///        onWaiting: () => CircularProgressIndicator(),
///        builder: (context, futureCRM) {
///            //
///            //here the three future are resolved and their values can be obtained
///            final futureAValue = IN.get<FutureA>();
///            final futureBValue = IN.get<FutureB>();
///            final futureCValue = IN.get<FutureC>();
///          },
///        );
///    },
///),
///```
///see also : [ReactiveModel], [RM.get] and [IN.get].
class Injector extends StatefulWidget {
  ///List of models to register (inject).
  ///
  ///**IMPORTANT: You can not inject more than one instance of a model.**
  ///**If you have to do that, use Inject with custom name.**
  ///example:
  ///```dart
  ///Injector(
  /// inject: [
  ///     Inject<int>(()=>1) // Inject a value
  ///     Inject<int>(()=>1,name:"var1") // Inject a value with a custom name
  ///     Inject<MyModel>(()=>MyModel()) // Inject a Model (dart class)
  ///     Inject<int>.stream(()=>myStream<int>(),initialValue:0) // Inject a stream with optional initial value
  ///     Inject<int>.future(()=>myFuture<int>(),initialValue:0) // Inject a future with optional initial value
  ///   ]
  ///)
  ///```
  final List<Injectable> inject;

  ///The builder closure. It takes as parameter the context.
  final Widget Function(BuildContext) builder;

  // ///if it is set to true all injected models will be disposed.
  // ///
  // ///Injected models are disposed by calling the 'dispose()' method if exists.
  // ///
  // ///In any of the injected classes you can define a 'dispose()' method to clean up resources.
  // final bool disposeModels;

  // ///By default refreshed model from [reinjectOn] will notify their observers.
  // ///
  // ///set [shouldNotifyOnReinjectOn] if you do not want to notify observers
  // final bool shouldNotifyOnReinjectOn;

  ///Function to execute in `initState` of the state.
  final void Function()? initState;

  ///Function to execute in `dispose` of the state.
  final void Function()? dispose;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context)? afterInitialBuild;

  ///Function to track app life cycle state. It takes as parameter the AppLifeCycleState.
  final void Function(AppLifecycleState)? appLifeCycle;

  ///Refresh the list of inject model,
  ///whenever any of the observables in the [reinjectOn] emits a notification
  final List<ReactiveModel>? reinjectOn;

  ///By default refreshed model from [reinjectOn] will notify their observers.
  ///
  ///set [shouldNotifyOnReinjectOn] if you do not want to notify observers
  final bool shouldNotifyOnReinjectOn;

  ///set to true for test. It allows for injecting mock instances.
  static bool enableTestMode = false;

  ///A class used to register (inject) models.
  const Injector({
    Key? key,
    // for injection
    required this.inject,
    required this.builder,
    //for app lifecycle
    this.initState,
    this.dispose,
    this.afterInitialBuild,
    this.appLifeCycle,
    this.reinjectOn,
    this.shouldNotifyOnReinjectOn = true,
    // this.disposeModels = false,
  }) : super(key: key);

  ///Get the singleton instance of a model registered with [Injector].
  static T get<T>({dynamic name, bool silent = false}) {
    final String _name = name == null ? '$T' : name.toString();

    final Inject<T> inject = _getInject<T>(_name, silent);

    return inject.injected.state;
  }

  ///Get the singleton [ReactiveModel] instance of a model registered with [Injector].
  static ReactiveModel<T> getAsReactive<T>({
    dynamic name,
    bool silent = false,
  }) {
    final String _name = name == null ? '$T' : name.toString();

    final Inject<T> inject = _getInject<T>(_name, silent);

    final reactiveModel = inject.injected;
    // assert(
    //   () {
    //     if (reactiveModel.state is StatesRebuilder) {
    //       throw Exception(
    //         'Injected model extends StatesRebuilder',
    //       );
    //     }
    //     return true;
    //   }(),
    // );

    return reactiveModel;
  }

  static Inject<T> _getInject<T>(String name, [bool silent = false]) {
    final Inject<dynamic>? inject =
        InjectorState.allRegisteredModelInApp[name]?.last;
    assert(
      () {
        if (silent != true && inject == null) {
          throw Exception(
            '$T is not registered yet.\nUser Injector to register it',
          );
        }
        return true;
      }(),
    );

    return inject as Inject<T>;
  }

  @Deprecated('user RM.env instead')
  static dynamic env;

  @override
  State<Injector> createState() {
    if (appLifeCycle == null) {
      return InjectorState();
    } else {
      return InjectorStateAppLifeCycle();
    }
  }
}

///
class InjectorState extends State<Injector> {
  ///Map contains all the registered models of the app
  static final Map<String, List<Inject<dynamic>>> allRegisteredModelInApp =
      <String, List<Inject<dynamic>>>{};

  List<Inject<dynamic>> _injects = [];
  @override
  void initState() {
    super.initState();

    _injects = List<Inject<dynamic>>.from(widget.inject);
    registerInjects(_injects);

    if (widget.reinjectOn != null) {
      for (ReactiveModel model in widget.reinjectOn!) {
        model.subscribeToRM((rm) {
          if (!rm!.hasData) {
            return;
          }
          for (Inject inj in widget.inject.cast<Inject>()) {
            inj.injected.refresh();
          }
        });
      }
    }

    widget.initState?.call();

    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => widget.afterInitialBuild!(context),
      );
    }
  }

  @override
  void dispose() {
    unregisterInjects(_injects);

    widget.dispose?.call();

    _injects.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

///State of injector mixin with WidgetsBindingObserver
class InjectorStateAppLifeCycle extends InjectorState
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.appLifeCycle!(state);
  }
}

// class _ObserverOfStatesRebuilder extends ObserverOfStatesRebuilder {
//   final void Function() updateCallback;
//   _ObserverOfStatesRebuilder(this.updateCallback);
//   @override
//   bool update([Function(BuildContext) onSetState, dynamic _]) {
//     updateCallback();
//     return true;
//   }
// }

///
abstract class IN {
  ///Get the plain injected object
  static T? get<T>({
    dynamic name,
    bool silent = false,
  }) {
    return Injector.get<T>(
      name: name,
      silent: silent,
    );
  }
}

void registerInjects(List<Inject<dynamic>> _injects) {
  for (Inject<dynamic> inject in _injects) {
    final name = inject.getName();
    inject.isGlobal = true;
    final lastInject = InjectorState.allRegisteredModelInApp[name];
    if (lastInject == null) {
      InjectorState.allRegisteredModelInApp[name] = [inject];
    } else {
      if (Injector.enableTestMode == false) {
        InjectorState.allRegisteredModelInApp[name]!.add(inject);
      }
    }
  }
}

void unregisterInjects(List<Inject<dynamic>> _injects) {
  for (Inject<dynamic> inject in _injects) {
    inject.injected.dispose();

    final name = inject.getName();
    final isRemoved =
        InjectorState.allRegisteredModelInApp[name]?.remove(inject);
    if (isRemoved != true) {
      continue;
    }

    if (InjectorState.allRegisteredModelInApp[name]!.isEmpty) {
      InjectorState.allRegisteredModelInApp.remove(name);
    }
  }
}

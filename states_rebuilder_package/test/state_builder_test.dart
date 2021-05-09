import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  late ReactiveModel<Model> model;
  setUp(() {
    model = ReactiveModel.create(Model());
  });

  testWidgets(
    'StateBuilder is subscribed without tag (context) and rebuild after get notified',
    (tester) async {
      final widget = StateBuilder(
        observe: () => model,
        builder: (ctx, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${model.state.counter}'),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);

      //increment and notify all observer
      model.state.increment();
      model.notify();
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      //increment and notify observe
      model.state.increment();
      model.notify();
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    },
  );

  testWidgets(
    'StateBuilder is subscribed with custom tag and rebuild after get notified',
    (tester) async {
      final widget = StateBuilder(
        observe: () => model,
        tag: 'tag1',
        builder: (ctx, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${model.state.counter}'),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);

      //increment and notify observer with custom tag
      model.state.increment();
      model.notify();
      // model.notify(['tag1']);
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    },
  );

//   testWidgets(
//     'StateBuilder is subscribed with list of custom tag and rebuild after get notified',
//     (tester) async {
//       final widget = StateBuilder(
//         observe: () => model,
//         tag: ['tag1', 'tag2'],
//         builder: (ctx, _) {
//           return Directionality(
//             textDirection: TextDirection.ltr,
//             child: Text('${model.state.counter}'),
//           );
//         },
//       );

//       await tester.pumpWidget(widget);
//       expect(find.text('0'), findsOneWidget);

//       //increment and notify observer with custom tag1
//       model.state.increment();
//       // model.notify(['tag1']);
//       await tester.pump();
//       expect(find.text('1'), findsOneWidget);

//       //increment and notify observer with custom tag2
//       model.state.increment();
//       // model.notify(['tag2']);
//       await tester.pump();
//       expect(find.text('2'), findsOneWidget);
//     },
//   );

//   testWidgets(
//     'StateBuilder is subscribed with list of custom dynamic tag and rebuild after get notified',
//     (tester) async {
//       final widget = StateBuilder(
//         observe: () => model,
//         tag: [Tags.tag1, 2],
//         builder: (ctx, _) {
//           return Directionality(
//             textDirection: TextDirection.ltr,
//             child: Text('${model.state.counter}'),
//           );
//         },
//       );

//       await tester.pumpWidget(widget);
//       expect(find.text('0'), findsOneWidget);

//       //increment and notify observer with custom Tags.tag1
//       model.state.increment();
//       // model.notify([Tags.tag1]);
//       await tester.pump();
//       expect(find.text('1'), findsOneWidget);

//       //increment and notify observer with custom 2
//       model.state.increment();
//       // model.notify([2]);
//       await tester.pump();
//       expect(find.text('2'), findsOneWidget);
//     },
//   );

//   testWidgets(
//     'StateBuilder when disposed remove tags',
//     (tester) async {
//       bool switcher = true;
//       final widget = StateBuilder(
//         observe: () => model,
//         tag: ['mainTag'],
//         builder: (ctx, _) {
//           return Directionality(
//             textDirection: TextDirection.ltr,
//             child: Builder(
//               builder: (context) {
//                 if (switcher) {
//                   return StateBuilder(
//                     observe: () => model,
//                     tag: 'childTag',
//                     builder: (context, _) {
//                       return Text('${model.state.counter}');
//                     },
//                   );
//                 }
//                 return Text('false');
//               },
//             ),
//           );
//         },
//       );

//       await tester.pumpWidget(widget);
//       expect(model.observerLength, equals(2));
//       expect(find.text('0'), findsOneWidget);

//       switcher = false;
//       // //model.notify(['mainTag']);
//       await tester.pump();
//       expect(model.observerLength, equals(1));
//       expect(find.text('false'), findsOneWidget);
//     },
//   );

//   testWidgets(
//     'StateBuilder when disposed and all tags are removed cleaner is called',
//     (tester) async {
//       bool switcher = true;
//       final model2 =
//           ReactiveModel(creator: () => Model(), initialState: Model());
//       int numberOfCleanerCall = 0;
//       model2.addCleaner(() {
//         numberOfCleanerCall++;
//       });
//       final widget = StateBuilder(
//         observe: () => model,
//         tag: ['mainTag'],
//         builder: (ctx, _) {
//           return Directionality(
//             textDirection: TextDirection.ltr,
//             child: Builder(
//               builder: (context) {
//                 if (switcher) {
//                   return StateBuilder(
//                     observe: () => model2,
//                     tag: 'childTag',
//                     builder: (context, _) {
//                       return Text('${model2.state.counter}');
//                     },
//                   );
//                 }
//                 return Text('false');
//               },
//             ),
//           );
//         },
//       );

//       await tester.pumpWidget(widget);
//       expect(model.observerLength, equals(1));
//       expect(model2.observerLength, equals(1));
//       expect(find.text('0'), findsOneWidget);

//       switcher = false;
//       //model.notify(['mainTag']);
//       await tester.pump();
//       expect(model.observerLength, equals(1));
//       expect(model2.observerLength, equals(0));
//       expect(numberOfCleanerCall, equals(1));
//       expect(find.text('false'), findsOneWidget);
//     },
//   );

  testWidgets(
    'StateBuilder subscribe to two model and rebuild',
    (tester) async {
      final model2 = ReactiveModel.create(Model());

      final widget = StateBuilder(
        observe: () => model,
        observeMany: [() => model2],
        builder: (ctx, _) {
          return Directionality(
              textDirection: TextDirection.ltr,
              child: Text('${model2.state.counter}'));
        },
      );

      await tester.pumpWidget(widget);
      expect(model.observerLength, equals(1));
      expect(model2.observerLength, equals(1));
      expect(find.text('0'), findsOneWidget);
      //
      model2.state.increment();
      model.notify();
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      //
      model2.state.increment();
      model2.notify();
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    },
  );

  testWidgets(
    'StateBuilder should call initState and afterInitialBuild and afterRebuild',
    (tester) async {
      int numberOfInitStateCall = 0;
      int numberOfAfterInitialBuildCall = 0;
      int numberOfAfterRebuildCall = 0;
      String lifeCycleTracker = '';
      final widget = StateBuilder(
        observe: () => model,
        initState: (_, __) {
          numberOfInitStateCall++;
          lifeCycleTracker += "initState, ";
        },
        afterInitialBuild: (_, __) {
          numberOfAfterInitialBuildCall++;
          lifeCycleTracker += "afterInitialBuild, ";
        },
        onRebuildState: (_, __) {
          numberOfAfterRebuildCall++;
          lifeCycleTracker += "afterRebuild, ";
        },
        builder: (ctx, _) {
          lifeCycleTracker += "build, ";
          return Directionality(
              textDirection: TextDirection.ltr,
              child: Text('${model.state.counter}'));
        },
      );

      await tester.pumpWidget(widget);

      expect(numberOfInitStateCall, equals(1));
      expect(numberOfAfterInitialBuildCall, equals(1));
      expect(numberOfAfterRebuildCall, equals(0));
      expect(lifeCycleTracker, equals('initState, build, afterInitialBuild, '));

      //
      model.notify();
      await tester.pump();
      expect(numberOfInitStateCall, equals(1));
      expect(numberOfAfterInitialBuildCall, equals(1));
      expect(numberOfAfterRebuildCall, equals(1));
      expect(lifeCycleTracker,
          equals('initState, build, afterInitialBuild, build, afterRebuild, '));
    },
  );

  testWidgets(
    'StateBuilder should call dispose callback',
    (tester) async {
      bool switcher = true;

      int numberOfDisposeCall = 0;

      final widget = StateBuilder(
        observe: () => model,
        tag: ['mainTag'],
        builder: (ctx, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                if (switcher) {
                  return StateBuilder(
                    observe: () => model,
                    tag: 'childTag',
                    dispose: (_, __) => numberOfDisposeCall++,
                    builder: (context, _) {
                      return Text('${model.state.counter}');
                    },
                  );
                }
                return Text('false');
              },
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(numberOfDisposeCall, equals(0));

      switcher = false;
      model.notify();
      //model.notify(['mainTag']);
      await tester.pump();
      expect(numberOfDisposeCall, equals(1));
    },
  );

  testWidgets(
    'StateBuilder should get the right exposed model',
    (tester) async {
      bool switcher = true;

      ReactiveModel<int> intRM = ReactiveModel.create(0);
      ReactiveModel<String> stringRM = ReactiveModel.create('');
      ReactiveModel? rmFromInitState;
      ReactiveModel? rmFromDispose;

      final widget = StateBuilder(
        observe: () => model,
        tag: ['mainTag'],
        builder: (ctx, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                if (switcher) {
                  return StateBuilder(
                    observeMany: [() => stringRM, () => intRM],
                    initState: (_, rm) {
                      rmFromInitState = rm;
                    },
                    dispose: (_, rm) {
                      rmFromDispose = rm;
                    },
                    builder: (context, _) {
                      return Text('${model.state.counter}');
                    },
                  );
                }
                return Text('false');
              },
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(rmFromInitState, equals(stringRM));

      intRM.setState((_) => 1);
      await tester.pump();

      switcher = false;
      model.notify();
      await tester.pump();
      expect(rmFromDispose, equals(stringRM));
    },
  );

  testWidgets(
    'StateBuilder should buildWithChild works',
    (tester) async {
      final widget = StateBuilder(
        observe: () => model,
        builderWithChild: (ctx, _, child) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: <Widget>[
                Text('${model.state.counter}'),
                child!,
              ],
            ),
          );
        },
        child: Text('${model.state.counter}'),
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsNWidgets(2));
      //
      model.state.increment();
      model.notify();
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'StateBuilder should onSetState and onRebuildState works',
    (tester) async {
      int numberOfOnSetStateCall = 0;
      int numberOfOnRebuildStateCall = 0;
      String lifeCycleTracker = '';
      final widget = StateBuilder(
        observe: () => model,
        onSetState: (_, __) {
          lifeCycleTracker += 'onSetState, ';
          numberOfOnSetStateCall++;
        },
        onRebuildState: (_, __) {
          lifeCycleTracker += 'onRebuildState, ';
          numberOfOnRebuildStateCall++;
        },
        builder: (ctx, _) {
          lifeCycleTracker += 'rebuild, ';
          return Directionality(
              textDirection: TextDirection.ltr,
              child: Text('${model.state.counter}'));
        },
      );

      await tester.pumpWidget(widget);
      expect(numberOfOnSetStateCall, equals(0));
      expect(numberOfOnRebuildStateCall, equals(0));
      expect(lifeCycleTracker, equals('rebuild, '));
      //
      model.notify();
      await tester.pump();
      expect(numberOfOnSetStateCall, equals(1));
      expect(numberOfOnRebuildStateCall, equals(1));
      expect(lifeCycleTracker,
          equals('rebuild, onSetState, rebuild, onRebuildState, '));
    },
  );

  testWidgets(
    'StateBuilder: should watch works for primitives',
    (tester) async {
      final model = ReactiveModel.create(Model());
      int numberOfRebuild = 0;
      final widget = StateBuilder(
        observe: () => model,
        watch: (_) {
          return model.state.counter;
        },
        builder: (ctx, _) {
          return Directionality(
              textDirection: TextDirection.ltr,
              child: Text('${++numberOfRebuild}'));
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('1'), findsOneWidget);

      //state do not change
      model.notify();
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      //state changes
      model.state.increment();
      model.notify();
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      //state do not change
      model.notify();
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      //state changes
      model.state.increment();
      model.notify();
      await tester.pump();
      expect(find.text('3'), findsOneWidget);

      //state do not change
      model.notify();
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
    },
  );

  testWidgets(
    'StateBuilder should watch works for reference type',
    (tester) async {
      int numberOfRebuild = 0;
      final widget = StateBuilder(
        observe: () => model,
        watch: (_) {
          List list = [model.state.counter];
          return list;
        },
        builder: (ctx, _) {
          return Directionality(
              textDirection: TextDirection.ltr,
              child: Text('${++numberOfRebuild}'));
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('1'), findsOneWidget);

      //state do not change
      model.notify();
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      //state changes
      model.state.increment();
      model.notify();
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      //state do not change
      model.notify();
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      //state changes
      model.state.increment();
      model.notify();
      await tester.pump();
      expect(find.text('3'), findsOneWidget);

      //state do not change
      model.notify();
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
    },
  );

  testWidgets(
    'StateBuilder should watch  get the right exposed model and work',
    (tester) async {
      int numberOfRebuild = 0;
      final intRM = ReactiveModel.create([0]);
      final stringRM = ReactiveModel.create(['']);
      ReactiveModel? exposedRM;
      final widget = StateBuilder(
        observeMany: [() => intRM, () => stringRM],
        watch: (rm) {
          exposedRM = rm;
          return rm?.state;
        },
        builder: (ctx, rm) {
          return Directionality(
              textDirection: TextDirection.ltr,
              child: Text('${++numberOfRebuild}'));
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('1'), findsOneWidget);
      expect(exposedRM == intRM, isTrue);

      //state do not change
      intRM.setState((_) => [0]);
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      //state do not change
      stringRM.setState((_) => ['str1']);
      await tester.pump();
      expect(exposedRM == stringRM, isTrue);

      expect(find.text('2'), findsOneWidget);

      //state do not change
      stringRM.setState((_) => ['str1']);
      await tester.pump();
      expect(exposedRM == stringRM, isTrue);

      expect(find.text('2'), findsOneWidget);

      //state changes
      intRM.setState((_) => [1]);
      await tester.pump();
      expect(find.text('3'), findsOneWidget);

      //state do not change
      intRM.setState((_) => [1]);
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
    },
  );

  testWidgets(
    "should string equality work : (== : true) (identical : false) (hashCode : true)",
    (WidgetTester tester) async {
      final s = {
        'list': [1],
      };
      final s1 = s.toString();
      final s2 = Map.from(s).toString();

      final _equality = s1 + '1' == s2 + '1';
      final _identical = identical(s1 + '1', s2 + '1');
      final _hashCode = (s1 + '1').hashCode == (s2 + '1').hashCode;

      expect(_equality, isTrue);
      expect(_identical, isFalse);
      expect(_hashCode, isTrue);
    },
  );
  testWidgets(
    "StateBuilder throw if no builder or builderWithChild ",
    (WidgetTester tester) async {
      expect(() => StateBuilder(observe: () => model), throwsAssertionError);
    },
  );

  testWidgets(
    "StateBuilder throw if builderWithChild is defined without child parameter",
    (WidgetTester tester) async {
      expect(
          () => StateBuilder(
                observe: () => model,
                builderWithChild: (_, __, child) => child ?? Container(),
              ),
          throwsAssertionError);
    },
  );

  testWidgets(
    "StateBuilder 'onSetState' is called /*one*/ many for each frame (_isDirty)",
    (WidgetTester tester) async {
      final model = ReactiveModel.create(Model());
      List<String> _rebuildTracker = [];
      await tester.pumpWidget(
        StateBuilder(
          observe: () => model,
          onSetState: (context, model) => _rebuildTracker.add('onSetState'),
          onRebuildState: (context, model) =>
              _rebuildTracker.add('onRebuildState'),
          builder: (_, __) {
            _rebuildTracker.add('rebuild');
            return Container();
          },
        ),
      );

      expect(_rebuildTracker, equals(['rebuild']));
      model.notify();
      model.notify();
      await tester.pump();
      await tester.pump();
      expect(
          _rebuildTracker,
          equals([
            'rebuild',
            'onSetState',
            'onSetState',
            'rebuild',
            'onRebuildState',
            'onRebuildState',
          ]));
    },
  );

  testWidgets(
    "StateBuilder throws if  models is null and a dynamic generic type is defined",
    (WidgetTester tester) async {
      final widget = StateBuilder(
        builder: (_, rm) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(tester.takeException(), isArgumentError);
    },
  );

  testWidgets(
    "StateBuilder expose the model that is defined in the generic type, int",
    (WidgetTester tester) async {
      ReactiveModel<int> intRM = ReactiveModel.create(0);
      ReactiveModel<String> stringRM = ReactiveModel.create('');

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: StateBuilder<int>(
          observeMany: [() => intRM, () => stringRM],
          builder: (_, rm) {
            final model = rm?.state;
            if (model is int) {
              return Text('int=$model');
            } else if (model is String) {
              return Text('string=$model');
            }
            return Container();
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('int=0'), findsOneWidget);
    },
  );

  testWidgets(
    "StateBuilder expose the model that is defined in the generic type, String",
    (WidgetTester tester) async {
      ReactiveModel<int> intRM = ReactiveModel.create(0);
      ReactiveModel<String> stringRM = ReactiveModel.create('');

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: StateBuilder<String>(
          observeMany: [() => intRM, () => stringRM],
          builder: (_, rm) {
            final model = rm?.state;
            if (model is int) {
              return Text('int=$model');
            } else if (model is String) {
              return Text('string=$model');
            }
            return Container();
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('string='), findsOneWidget);
    },
  );

  testWidgets(
    "StateBuilder expose the model that emits a notification if generic type is dynamic",
    (WidgetTester tester) async {
      ReactiveModel<int> intRM = ReactiveModel.create(0);
      ReactiveModel<String> stringRM = ReactiveModel.create('');

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: StateBuilder(
          observeMany: [() => intRM, () => stringRM],
          builder: (_, rm) {
            final model = rm?.state;
            if (model is int) {
              return Text('int=$model');
            } else if (model is String) {
              return Text('string=$model');
            }
            return Container();
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('int=0'), findsOneWidget);
      //
      stringRM.setState((_) => 'str1');
      await tester.pump();
      expect(find.text('int=0'), findsNothing);
      expect(find.text('string=str1'), findsOneWidget);
      //
      intRM.setState((_) => 1);
      await tester.pump();
      expect(find.text('int=1'), findsOneWidget);
      expect(find.text('string=str1'), findsNothing);
    },
  );

  testWidgets(
      "StateBuilder should work with ReactiveModel.create when widget is updated",
      (WidgetTester tester) async {
    late ReactiveModel<int> modelRM1;
    late ReactiveModel<int> modelRM2;

    final widget = Builder(
      builder: (context) {
        modelRM1 = ReactiveModel.create(0);
        return MaterialApp(
          home: Column(
            children: <Widget>[
              StateBuilder(
                  observe: () => modelRM1,
                  builder: (_, __) {
                    return Column(
                      children: <Widget>[
                        Text('modelRM1-${modelRM1.state}'),
                        Builder(
                          builder: (context) {
                            return StateBuilder<int>(
                                observe: () => ReactiveModel.create(0),
                                builder: (_, rm) {
                                  modelRM2 = rm!;
                                  return Text('modelRM2-${modelRM2.state}');
                                });
                          },
                        ),
                      ],
                    );
                  }),
            ],
          ),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-0'), findsOneWidget);
    //
    modelRM2.setState((_) => 1);
    await tester.pump();
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-1'), findsOneWidget);
    expect(modelRM2.hasData, isTrue);

    modelRM1.setState((_) => 1);
    await tester.pump();
    expect(find.text('modelRM1-1'), findsOneWidget);
    expect(find.text('modelRM2-1'), findsOneWidget);
    expect(modelRM2.hasData, isTrue);

    modelRM2.setState((_) => modelRM2.state + 1);
    await tester.pump();
    expect(find.text('modelRM1-1'), findsOneWidget);
    expect(find.text('modelRM2-2'), findsOneWidget);
  });

  testWidgets(
    'StateBuilder should call didChangeDependencies and didUpdateWidget ',
    (tester) async {
      bool switcher = true;
      int numberOfDidChangeDependencies = 0;
      int numberOfDidUpdateWidget = 0;
      final widget = StateBuilder(
        observe: () => model,
        tag: ['mainTag'],
        builder: (ctx, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                if (switcher) {
                  return StateBuilder(
                    didChangeDependencies: (_, __) {
                      numberOfDidChangeDependencies++;
                    },
                    didUpdateWidget: (_, __, ___) {
                      numberOfDidUpdateWidget++;
                    },
                    observe: () => model,
                    tag: 'childTag',
                    builder: (context, _) {
                      return Text('${model.state.counter}');
                    },
                  );
                }
                return Text('false');
              },
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(numberOfDidChangeDependencies, equals(1));
      expect(numberOfDidUpdateWidget, equals(0));

      model.notify();
      await tester.pump();

      expect(numberOfDidChangeDependencies, equals(1));
      expect(numberOfDidUpdateWidget, equals(1));

      switcher = false;
      //model.notify(['mainTag']);
      await tester.pump();
      expect(numberOfDidChangeDependencies, equals(1));
      expect(numberOfDidUpdateWidget, equals(1));
    },
  );

  testWidgets(
      'issue #52, cleaner should not be called if widget did change with the same list of models',
      (tester) async {
    int numberOfDidUpdateWidget = 0;
    int numberOfCleaner = 0;
    final model1 = ReactiveModel.create(Model());
    final widget = StateBuilder(
      observe: () => model,
      tag: ['mainTag'],
      builder: (ctx, _) {
        return StateBuilder(
          observeMany: [() => model1],
          didUpdateWidget: (_, __, ___) {
            numberOfDidUpdateWidget++;
          },
          builder: (context, _) {
            return Container();
          },
        );
      },
    );
    //
    model1.addCleaner(() {
      numberOfCleaner++;
    });
    //
    await tester.pumpWidget(widget);
    expect(numberOfDidUpdateWidget, equals(0));
    expect(numberOfCleaner, equals(0));
    //
    model.notify();
    await tester.pump();

    expect(numberOfDidUpdateWidget, equals(1));
    expect(numberOfCleaner, equals(0));
  });
}

class Model {
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }

  dispose() {
    numberOfDisposeCall++;
  }
}

class ModelWithoutDispose extends StatesRebuilder {
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }
}

enum Tags { tag1, tag2, tag3 }

class StatesRebuilder extends Injected {
  void rebuildStates([List? tags]) {}
  int get observerLength => 0;
  @override
  bool get canRedoState => throw UnimplementedError();

  @override
  bool get canUndoState => throw UnimplementedError();

  @override
  void clearUndoStack() {}

  @override
  void deletePersistState() {}

  @override
  Widget inherited(
      {required Widget Function(BuildContext p1) builder,
      Key? key,
      Function()? stateOverride,
      bool connectWithGlobal = true,
      String? debugPrintWhenNotifiedPreMessage,
      String Function(dynamic s)? toDebugString}) {
    throw UnimplementedError();
  }

  @override
  void injectFutureMock(Future Function() fakeCreator) {}

  @override
  void injectMock(Function() fakeCreator) {}

  @override
  void injectStreamMock(Stream Function() fakeCreator) {}

  @override
  void persistState() {}

  @override
  Widget reInherited(
      {Key? key,
      required BuildContext context,
      required Widget Function(BuildContext p1) builder}) {
    throw UnimplementedError();
  }

  @override
  void redoState() {}

  @override
  void undoState() {}
}

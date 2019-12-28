import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'should throw if both builder and builderWith parameters are not defined',
    (WidgetTester tester) async {
      final vm = ViewModel();

      expect(
        () => tester.pumpWidget(StateBuilder(
          models: [vm],
          tag: "myTag",
        )),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    'should throw if both builderWith parameter is defined without child parameter',
    (WidgetTester tester) async {
      final vm = ViewModel();

      expect(
        () => tester.pumpWidget(StateBuilder(
          models: [vm],
          tag: "myTag",
          builderWithChild: (context, _, __) {
            return Container();
          },
        )),
        throwsAssertionError,
      );
    },
  );

  testWidgets('StateBuilder with one tag, rebuild state with this tag works',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID;
    bool isRebuilt = false;

    final widget = StateBuilder(
      models: [vm],
      tag: "myTag",
      builder: (context, model) {
        _tagID = context;
        isRebuilt = true;
        return Container();
      },
    );

    expect(_tagID, isNull);

    await tester.pumpWidget(widget);

    expect(vm.observers().length, equals(2));

    isRebuilt = false;
    vm.rebuildStates(["noRegisteredTag"]);
    await tester.pump();
    expect(isRebuilt, isFalse);

    isRebuilt = false;
    vm.rebuildStates();
    await tester.pump();
    expect(isRebuilt, isTrue);

    isRebuilt = false;
    vm.rebuildStates([_tagID]);
    await tester.pump();
    expect(isRebuilt, isTrue);
  });

  testWidgets(
      'StateBuilder with list of tags, the state is registered with these tag',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID;
    final widget = StateBuilder(
      models: [vm],
      tag: ["myTag1", "myTag2"],
      builder: (context, model) {
        _tagID = context;
        return Container();
      },
    );

    expect(_tagID, isNull);

    await tester.pumpWidget(widget);

    expect(vm.observers().length, equals(3));
  });

  testWidgets(
      'StateBuilder with list of tags rebuild state with this tag works with AfterRebuildCallBack check',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID;
    bool isRebuilt = false;

    final widget = StateBuilder(
      models: [vm],
      tag: ["myTag1", "myTag2"],
      builder: (context, model) {
        _tagID = context;
        isRebuilt = true;
        return Container();
      },
    );

    expect(_tagID, isNull);

    await tester.pumpWidget(widget);

    expect(vm.observers().length, equals(3));

    isRebuilt = false;
    vm.rebuildStates(["noRegisteredTag"]);
    await tester.pump();
    expect(isRebuilt, isFalse);

    isRebuilt = false;
    vm.rebuildStates();
    await tester.pump();
    expect(isRebuilt, isTrue);

    isRebuilt = false;
    vm.rebuildStates(["myTag1"]);
    await tester.pump();
    expect(isRebuilt, isTrue);

    isRebuilt = false;
    vm.rebuildStates(["myTag2"]);
    await tester.pump();
    expect(isRebuilt, isTrue);

    int numberOFCallOfAfterRebuildCallBack = 0;
    vm.rebuildStates(null, (context) {
      numberOFCallOfAfterRebuildCallBack++;
    });
    await tester.pump();

    expect(numberOFCallOfAfterRebuildCallBack, 1);
    isRebuilt = false;
  });

  testWidgets('afterRebuildCallback works', (WidgetTester tester) async {
    final vm = ViewModel();
    bool isRebuilt = false;
    List<String> _rebuildTracker = [];
    final widget = StateBuilder(
      models: [vm],
      disposeModels: true,
      builder: (context, model) {
        isRebuilt = true;
        _rebuildTracker.add("build");
        return Container();
      },
    );

    expect(isRebuilt, isFalse);
    await tester.pumpWidget(widget);
    isRebuilt = false;
    vm.rebuildStates(null, (context) => _rebuildTracker.add("afterBuild"));
    await tester.pump();
    expect(isRebuilt, isTrue);
    expect(_rebuildTracker, ["build", "afterBuild", "build"]);
  });

  testWidgets(
      'many StateBuilder with different tags, the state is registered with these tag',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID1;
    var _tagID2;
    final widget1 = StateBuilder(
      models: [vm],
      tag: "myTag1",
      builder: (context, model) {
        _tagID1 = context;
        return Container();
      },
    );

    final widget2 = StateBuilder(
      models: [vm],
      tag: "myTag2",
      builder: (context, model) {
        _tagID2 = context;
        return Container();
      },
    );

    expect(_tagID1, isNull);
    expect(_tagID2, isNull);

    await tester.pumpWidget(Column(
      children: <Widget>[
        widget1,
        widget2,
      ],
    ));

    expect(vm.observers().length, equals(4));
  });

  testWidgets(
      'many StateBuilder with different tags, rebuild states works, with afterRebuildCallBack',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID1;
    var _tagID2;
    bool isRebuilt1 = false;
    bool isRebuilt2 = false;
    BuildContext cxt1;
    BuildContext cxt2;
    final widget1 = StateBuilder(
      models: [vm],
      tag: "myTag1",
      builder: (context, model) {
        _tagID1 = context;
        isRebuilt1 = true;
        return Container();
      },
    );

    final widget2 = StateBuilder(
      models: [vm],
      tag: "myTag2",
      builder: (context, model) {
        cxt1 = context;
        _tagID2 = context;
        isRebuilt2 = true;
        return Container();
      },
    );

    await tester.pumpWidget(Column(
      children: <Widget>[
        widget1,
        widget2,
      ],
    ));

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates(["noRegisteredTag"]);
    await tester.pump();
    expect(isRebuilt1, isFalse);
    expect(isRebuilt2, isFalse);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates();
    await tester.pump();
    expect(isRebuilt1, isTrue);
    expect(isRebuilt2, isTrue);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates(['myTag1']);
    await tester.pump();
    expect(isRebuilt1, isTrue);
    expect(isRebuilt2, isFalse);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates(['myTag2']);
    await tester.pump();
    expect(isRebuilt1, isFalse);
    expect(isRebuilt2, isTrue);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates([_tagID1]);
    await tester.pump();
    expect(isRebuilt1, isTrue);
    expect(isRebuilt2, isFalse);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates([_tagID2]);
    await tester.pump();
    expect(isRebuilt1, isFalse);
    expect(isRebuilt2, isTrue);

    int numberOFCallOfAfterRebuildCallBack = 0;
    vm.rebuildStates(null, (context) {
      numberOFCallOfAfterRebuildCallBack++;
      cxt2 = context;
    });
    await tester.pump();
    expect(numberOFCallOfAfterRebuildCallBack, 1);
    expect(cxt1, cxt2);
  });

  testWidgets(
      'many StateBuilder with the same tags, the state is registered with this tag',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID1;
    var _tagID2;
    final widget1 = StateBuilder(
      models: [vm],
      tag: "myTag",
      builder: (context, model) {
        _tagID1 = context;
        return Container();
      },
    );

    final widget2 = StateBuilder(
      models: [vm],
      tag: "myTag",
      builder: (context, model) {
        _tagID2 = context;
        return Container();
      },
    );

    expect(_tagID1, isNull);
    expect(_tagID2, isNull);

    await tester.pumpWidget(Column(
      children: <Widget>[
        widget1,
        widget2,
      ],
    ));
    expect(vm.observers().length, equals(3));
  });

  testWidgets('many StateBuilder with the same tag, rebuild states works',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID1;
    var _tagID2;
    bool isRebuilt1 = false;
    bool isRebuilt2 = false;
    final widget1 = StateBuilder(
      models: [vm],
      tag: "myTag",
      builder: (context, model) {
        _tagID1 = context;
        isRebuilt1 = true;
        return Container();
      },
    );

    final widget2 = StateBuilder(
      models: [vm],
      tag: "myTag",
      builder: (context, model) {
        _tagID2 = context;
        isRebuilt2 = true;
        return Container();
      },
    );

    await tester.pumpWidget(Column(
      children: <Widget>[
        widget1,
        widget2,
      ],
    ));

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates(["noRegisteredTag"]);
    await tester.pump();
    expect(isRebuilt1, isFalse);
    expect(isRebuilt2, isFalse);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates();
    await tester.pump();
    expect(isRebuilt1, isTrue);
    expect(isRebuilt2, isTrue);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates(['myTag']);
    await tester.pump();
    expect(isRebuilt1, isTrue);
    expect(isRebuilt2, isTrue);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates([_tagID1]);
    await tester.pump();
    expect(isRebuilt1, isTrue);
    expect(isRebuilt2, isFalse);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates([_tagID2]);
    await tester.pump();
    expect(isRebuilt1, isFalse);
    expect(isRebuilt2, isTrue);
  });

  testWidgets('dispose StateBuilders with the different tags works',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID1;
    var _tagID2;

    bool initStateIsCalled1 = false;
    bool initStateIsCalled2 = false;
    bool disposeIsCalled1 = false;
    bool disposeIsCalled2 = false;

    final widget1 = StateBuilder(
      key: UniqueKey(),
      models: [vm],
      initState: (context, model) {
        _tagID1 = context;
        initStateIsCalled1 = true;
      },
      dispose: (context, model) => disposeIsCalled1 = true,
      tag: "myTag1",
      builder: (context, model) => Container(),
    );

    final widget2 = StateBuilder(
      key: UniqueKey(),
      models: [vm],
      initState: (context, model) {
        _tagID2 = context;
        initStateIsCalled2 = true;
      },
      dispose: (context, model) => disposeIsCalled2 = true,
      tag: "myTag2",
      builder: (context, model) => Container(),
    );
    bool switcher = true;
    await tester.pumpWidget(StateBuilder(
      models: [vm],
      tag: "mainState",
      builderWithChild: (_, __, ___) => switcher ? widget1 : widget2,
      child: Container(),
    ));

    expect(vm.observers().length, equals(4));
    expect(vm.observers()["myTag1"].length, equals(1));
    expect(vm.observers()["myTag2"], null);
    expect(_tagID1, isNotNull);
    expect(_tagID2, isNull);

    expect(initStateIsCalled1, isTrue);
    expect(initStateIsCalled2, isFalse);
    expect(disposeIsCalled1, isFalse);
    expect(disposeIsCalled2, isFalse);

    initStateIsCalled1 = false;
    initStateIsCalled2 = false;
    disposeIsCalled1 = false;
    disposeIsCalled2 = false;

    switcher = false;
    vm.rebuildStates(["mainState"]);

    await tester.pump();

    expect(vm.observers().length, equals(4));
    expect(vm.observers()["myTag1"], null);
    expect(vm.observers()["myTag2"].length, equals(1));

    expect(initStateIsCalled1, isFalse);
    expect(initStateIsCalled2, isTrue);
    expect(disposeIsCalled1, isTrue);
    expect(disposeIsCalled2, isFalse);
  });

  testWidgets('dispose StateBuilders with the same tags works',
      (WidgetTester tester) async {
    final vm = ViewModel();
    var _tagID1;
    var _tagID2;

    bool initStateIsCalled1 = false;
    bool initStateIsCalled2 = false;
    bool disposeIsCalled1 = false;
    bool disposeIsCalled2 = false;

    final widget1 = StateBuilder(
      key: UniqueKey(),
      models: [vm],
      initState: (context, model) {
        _tagID1 = context;
        initStateIsCalled1 = true;
      },
      dispose: (context, model) => disposeIsCalled1 = true,
      tag: "myTag",
      builder: (context, model) => Container(),
    );

    final widget2 = StateBuilder(
      key: UniqueKey(),
      models: [vm],
      initState: (context, model) {
        _tagID2 = context;
        initStateIsCalled2 = true;
      },
      dispose: (context, model) => disposeIsCalled2 = true,
      tag: "myTag",
      builder: (context, model) => Container(),
    );
    bool switcher = true;
    await tester.pumpWidget(StateBuilder(
      models: [vm],
      tag: "mainState",
      builder: (_, __) => Column(
        children: <Widget>[switcher ? widget1 : Container(), widget2],
      ),
    ));
    expect(vm.observers().length, equals(5));
    expect(vm.observers()["myTag"].length, equals(2));
    expect(_tagID1, isNotNull);
    expect(_tagID2, isNotNull);

    expect(initStateIsCalled1, isTrue);
    expect(initStateIsCalled2, isTrue);
    expect(disposeIsCalled1, isFalse);
    expect(disposeIsCalled2, isFalse);

    initStateIsCalled1 = false;
    initStateIsCalled2 = false;
    disposeIsCalled1 = false;
    disposeIsCalled2 = false;

    switcher = false;
    vm.rebuildStates(["mainState"]);

    await tester.pump();

    expect(vm.observers().length, equals(4));
    expect(vm.observers()["myTag"].length, equals(1));
    expect(_tagID1, isNotNull);
    expect(_tagID2, isNotNull);

    expect(initStateIsCalled1, isFalse);
    expect(initStateIsCalled2, isFalse);
    expect(disposeIsCalled1, isTrue);
    expect(disposeIsCalled2, isFalse);
  });

  testWidgets(
    "'afterMounted' is called once after the widget insertion in the widget tree",
    (WidgetTester tester) async {
      final vm = ViewModel();
      int numberOfCall = 0;
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          afterInitialBuild: (context, model) => numberOfCall++,
          builder: (_, __) => Container(height: 20, width: 20),
        ),
      );

      expect(numberOfCall, 1);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 1);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 1);
    },
  );

  testWidgets(
    "'afterRebuild' is called once after the widget rebuild",
    (WidgetTester tester) async {
      final vm = ViewModel();
      int numberOfCall = 0;
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          afterRebuild: (context, model) => numberOfCall++,
          builder: (_, __) => Container(),
        ),
      );
      expect(numberOfCall, 1);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 2);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 3);
    },
  );

  testWidgets(
    "'afterInitialBuild' and 'afterRebuild' called together",
    (WidgetTester tester) async {
      final vm = ViewModel();
      List<String> _rebuildTracker = [];

      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          afterInitialBuild: (context, model) =>
              _rebuildTracker.add('afterInitialBuild'),
          afterRebuild: (context, model) => _rebuildTracker.add('afterRebuild'),
          builder: (_, __) {
            _rebuildTracker.add('rebuild');
            return Container();
          },
        ),
      );

      expect(_rebuildTracker,
          equals(['rebuild', 'afterInitialBuild', 'afterRebuild']));
      vm.rebuildStates();
      await tester.pump();
      expect(
          _rebuildTracker,
          equals([
            'rebuild',
            'afterInitialBuild',
            'afterRebuild',
            'rebuild',
            'afterRebuild'
          ]));
    },
  );

  testWidgets(
    "should 'onSetState' and 'onRebuildState' work",
    (WidgetTester tester) async {
      final vm = ViewModel();
      List<String> _rebuildTracker = [];
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
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
      vm.rebuildStates();
      await tester.pump();
      expect(_rebuildTracker,
          equals(['rebuild', 'onSetState', 'rebuild', 'onRebuildState']));
    },
  );

  testWidgets(
    "should 'onSetState' is called one for each frame (_isDirty)",
    (WidgetTester tester) async {
      final vm = ViewModel();
      List<String> _rebuildTracker = [];
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
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
      vm.rebuildStates();
      vm.rebuildStates();
      await tester.pump();
      expect(_rebuildTracker,
          equals(['rebuild', 'onSetState', 'rebuild', 'onRebuildState']));
    },
  );
}

class ViewModel extends StatesRebuilder {}

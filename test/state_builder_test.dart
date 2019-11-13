import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('Throw exception if no models is provided',
      (WidgetTester tester) async {
    expect(() {
      StateBuilder(
        builder: (context, tagID) {
          return Container();
        },
      );
    }, throwsException);
  });
  testWidgets('StateBuilder without tags, default tag is created',
      (WidgetTester tester) async {
    final vm = ViewModel();
    String _tagID;
    final widget = StateBuilder(
      viewModels: [vm],
      builder: (context, tagID) {
        _tagID = tagID;
        return Container();
      },
    );

    expect(_tagID, isNull);

    await tester.pumpWidget(widget);

    expect(vm.observers().length, equals(1));
    expect(_tagID, startsWith("#@deFau_Lt"));
  });

  testWidgets('StateBuilder with one tag, rebuild state with this tag works',
      (WidgetTester tester) async {
    final vm = ViewModel();
    String _tagID;
    bool isRebuilt = false;

    final widget = StateBuilder(
      viewModels: [vm],
      tag: "myTag",
      builder: (context, tagID) {
        _tagID = tagID;
        isRebuilt = true;
        return Container();
      },
    );

    expect(_tagID, isNull);

    await tester.pumpWidget(widget);

    expect(vm.observers().length, equals(1));
    expect(_tagID, startsWith("myTag"));

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
    String _tagID;
    final widget = StateBuilder(
      viewModels: [vm],
      tag: ["myTag1", "myTag2"],
      builder: (context, tagID) {
        _tagID = tagID;
        return Container();
      },
    );

    expect(_tagID, isNull);

    await tester.pumpWidget(widget);

    expect(vm.observers().length, equals(3));
    expect(_tagID, startsWith("#@deFau_Lt"));
  });

  testWidgets(
      'StateBuilder with list of tags rebuild state with this tag works with AfterRebuildCallBack check',
      (WidgetTester tester) async {
    final vm = ViewModel();
    String _tagID;
    bool isRebuilt = false;

    final widget = StateBuilder(
      viewModels: [vm],
      tag: ["myTag1", "myTag2"],
      builder: (context, tagID) {
        _tagID = tagID;
        isRebuilt = true;
        return Container();
      },
    );

    expect(_tagID, isNull);

    await tester.pumpWidget(widget);

    expect(vm.observers().length, equals(3));
    expect(_tagID, startsWith("#@deFau_Lt"));

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
    print(_tagID);
    expect(_tagID, startsWith("#@deFau_Lt"));
  });

  testWidgets('afterRebuildCallback works', (WidgetTester tester) async {
    final vm = ViewModel();
    bool isRebuilt = false;
    List<String> _rebuildTracker = [];
    final widget = StateBuilder(
      viewModels: [vm],
      builder: (context, tagID) {
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
    String _tagID1;
    String _tagID2;
    final widget1 = StateBuilder(
      viewModels: [vm],
      tag: "myTag1",
      builder: (context, tagID) {
        _tagID1 = tagID;
        return Container();
      },
    );

    final widget2 = StateBuilder(
      viewModels: [vm],
      tag: "myTag2",
      builder: (context, tagID) {
        _tagID2 = tagID;
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

    expect(vm.observers().length, equals(2));
    expect(_tagID1, startsWith("myTag1"));
    expect(_tagID2, startsWith("myTag2"));
  });

  testWidgets(
      'many StateBuilder with different tags, rebuild states works, with afterRebuildCallBack',
      (WidgetTester tester) async {
    final vm = ViewModel();
    String _tagID1;
    String _tagID2;
    bool isRebuilt1 = false;
    bool isRebuilt2 = false;
    BuildContext cxt1;
    BuildContext cxt2;
    final widget1 = StateBuilder(
      viewModels: [vm],
      tag: "myTag1",
      builder: (context, tagID) {
        _tagID1 = tagID;
        isRebuilt1 = true;
        return Container();
      },
    );

    final widget2 = StateBuilder(
      viewModels: [vm],
      tag: "myTag2",
      builder: (context, tagID) {
        cxt1 = context;
        _tagID2 = tagID;
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
    String _tagID1;
    String _tagID2;
    final widget1 = StateBuilder(
      viewModels: [vm],
      tag: "myTag",
      builder: (context, tagID) {
        _tagID1 = tagID;
        return Container();
      },
    );

    final widget2 = StateBuilder(
      viewModels: [vm],
      tag: "myTag",
      builder: (context, tagID) {
        _tagID2 = tagID;
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
    expect(vm.observers().length, equals(1));
    expect(_tagID1, "myTag");
    expect(_tagID2, "myTag");
  });

  testWidgets('many StateBuilder with the same tag, rebuild states works',
      (WidgetTester tester) async {
    final vm = ViewModel();
    String _tagID1;
    String _tagID2;
    bool isRebuilt1 = false;
    bool isRebuilt2 = false;
    final widget1 = StateBuilder(
      viewModels: [vm],
      tag: "myTag",
      builder: (context, tagID) {
        _tagID1 = tagID;
        isRebuilt1 = true;
        return Container();
      },
    );

    final widget2 = StateBuilder(
      viewModels: [vm],
      tag: "myTag",
      builder: (context, tagID) {
        _tagID2 = tagID;
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
    print(_tagID1);
    vm.rebuildStates([_tagID1]);
    await tester.pump();
    expect(isRebuilt1, isTrue);
    expect(isRebuilt2, isTrue);

    isRebuilt1 = false;
    isRebuilt2 = false;
    vm.rebuildStates([_tagID2]);
    await tester.pump();
    expect(isRebuilt1, isTrue);
    expect(isRebuilt2, isTrue);
  });

  testWidgets('dispose StateBuilders with the different tags works',
      (WidgetTester tester) async {
    final vm = ViewModel();
    String _tagID1;
    String _tagID2;

    bool initStateIsCalled1 = false;
    bool initStateIsCalled2 = false;
    bool disposeIsCalled1 = false;
    bool disposeIsCalled2 = false;

    final widget1 = StateBuilder(
      key: UniqueKey(),
      viewModels: [vm],
      initState: (context, tagID) {
        _tagID1 = tagID;
        initStateIsCalled1 = true;
      },
      dispose: (context, tagID) => disposeIsCalled1 = true,
      tag: "myTag1",
      builder: (context, tagID) => Container(),
    );

    final widget2 = StateBuilder(
      key: UniqueKey(),
      viewModels: [vm],
      initState: (context, tagID) {
        _tagID2 = tagID;
        initStateIsCalled2 = true;
      },
      dispose: (context, tagID) => disposeIsCalled2 = true,
      tag: "myTag2",
      builder: (context, tagID) => Container(),
    );
    bool switcher = true;
    await tester.pumpWidget(StateBuilder(
      viewModels: [vm],
      tag: "mainState",
      builder: (_, __) => switcher ? widget1 : widget2,
    ));

    expect(vm.observers().length, equals(2));
    expect(vm.observers()["myTag1"].length, equals(1));
    expect(vm.observers()["myTag2"], null);
    expect(_tagID1, startsWith("myTag1"));
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

    expect(vm.observers().length, equals(2));
    expect(vm.observers()["myTag1"], null);
    expect(vm.observers()["myTag2"].length, equals(1));
    expect(_tagID1, startsWith("myTag1"));
    expect(_tagID2, startsWith("myTag2"));

    expect(initStateIsCalled1, isFalse);
    expect(initStateIsCalled2, isTrue);
    expect(disposeIsCalled1, isTrue);
    expect(disposeIsCalled2, isFalse);
  });

  testWidgets('dispose StateBuilders with the same tags works',
      (WidgetTester tester) async {
    final vm = ViewModel();
    String _tagID1;
    String _tagID2;

    bool initStateIsCalled1 = false;
    bool initStateIsCalled2 = false;
    bool disposeIsCalled1 = false;
    bool disposeIsCalled2 = false;

    final widget1 = StateBuilder(
      key: UniqueKey(),
      viewModels: [vm],
      initState: (context, tagID) {
        _tagID1 = tagID;
        initStateIsCalled1 = true;
      },
      dispose: (context, tagID) => disposeIsCalled1 = true,
      tag: "myTag",
      builder: (context, tagID) => Container(),
    );

    final widget2 = StateBuilder(
      key: UniqueKey(),
      viewModels: [vm],
      initState: (context, tagID) {
        _tagID2 = tagID;
        initStateIsCalled2 = true;
      },
      dispose: (context, tagID) => disposeIsCalled2 = true,
      tag: "myTag",
      builder: (context, tagID) => Container(),
    );
    bool switcher = true;
    await tester.pumpWidget(StateBuilder(
      viewModels: [vm],
      tag: "mainState",
      builder: (_, __) => Column(
        children: <Widget>[switcher ? widget1 : Container(), widget2],
      ),
    ));

    expect(vm.observers().length, equals(2));
    expect(vm.observers()["myTag"].length, equals(2));
    expect(_tagID1, startsWith("myTag"));
    expect(_tagID2, startsWith("myTag"));

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

    expect(vm.observers().length, equals(2));
    expect(vm.observers()["myTag"].length, equals(1));
    expect(_tagID1, startsWith("myTag"));
    expect(_tagID2, startsWith("myTag"));

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
          viewModels: [vm],
          afterInitialBuild: (context, tagID) => numberOfCall++,
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
          viewModels: [vm],
          afterRebuild: (context, tagID) => numberOfCall++,
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
    "'afterMounted' and 'afterRebuild' called together",
    (WidgetTester tester) async {
      final vm = ViewModel();
      int numberOfCall = 0;
      await tester.pumpWidget(
        StateBuilder(
          viewModels: [vm],
          afterInitialBuild: (context, tagID) => numberOfCall++,
          afterRebuild: (context, tagID) => numberOfCall++,
          builder: (_, __) => Container(),
        ),
      );

      expect(numberOfCall, 2);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 3);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 4);
    },
  );
}

class ViewModel extends StatesRebuilder {}

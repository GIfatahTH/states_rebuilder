import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/split_and_add_observer.dart';
import 'package:states_rebuilder/src/state_builder.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

void main() {
  ViewModel vm;
  StatesRebuilderListener1 observer;
  setUp(() {
    vm = ViewModel();
    observer = StatesRebuilderListener1();
    isUpdatedObserver1 = false;
  });
  group("addToObserver : ", () {
    test("When viewModels = null, Do nothing", () {
      final myWidget = StateBuilder(
        viewModels: [null],
        builder: (_, __) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      expect(splitAndAdd.tag.length, equals(1));
      expect(splitAndAdd.defaultTag, isNull);
    });
    test("When viewModels is empty, Do nothing", () {
      final myWidget = StateBuilder(
        viewModels: [],
        builder: (_, __) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      expect(splitAndAdd.tag.length, equals(0));
      expect(splitAndAdd.defaultTag, isNull);
    });
    test("When no tag is provided, create default one and add observer", () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      expect(splitAndAdd.tag[0], startsWith("#@deFau_Lt"));
    });

    test(
        "with no tag is provided, when rebuildStates is called without arguments or with tagID, it will rebuild",
        () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      isUpdatedObserver1 = false;
      vm.rebuildStates();
      expect(isUpdatedObserver1, isTrue);

      isUpdatedObserver1 = false;
      vm.rebuildStates([splitAndAdd.defaultTag]);
      expect(isUpdatedObserver1, isTrue);
    });

    test(
        "When no tag is provided, create default one and add observer case many StateBuilder",
        () {
      final myWidget1 = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final observer2 = StatesRebuilderListener2();

      final splitAndAdd1 = SplitAndAddObserver(myWidget1, observer);
      final splitAndAdd2 = SplitAndAddObserver(myWidget2, observer2);

      expect(splitAndAdd1.tag.length, equals(1));
      expect(splitAndAdd1.tag[0], startsWith("#@deFau_Lt"));
      expect(splitAndAdd1.defaultTag, endsWith("TaG30"));
      expect(splitAndAdd1.defaultTag, startsWith(splitAndAdd1.tag[0]));

      expect(splitAndAdd2.tag.length, equals(1));
      expect(splitAndAdd2.tag[0], startsWith("#@deFau_Lt"));
      expect(splitAndAdd2.defaultTag, startsWith(splitAndAdd2.tag[0]));
    });

    test("When no tag is provided, rebuildStates works", () {
      final myWidget1 = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final observer2 = StatesRebuilderListener2();

      final splitAndAdd1 = SplitAndAddObserver(myWidget1, observer);
      final splitAndAdd2 = SplitAndAddObserver(myWidget2, observer2);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;
      vm.rebuildStates();
      expect(isUpdatedObserver1, isTrue);
      expect(isUpdatedObserver2, isTrue);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;
      vm.rebuildStates([splitAndAdd1.defaultTag]);
      expect(isUpdatedObserver1, isTrue);
      expect(isUpdatedObserver2, isFalse);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;

      vm.rebuildStates([splitAndAdd2.defaultTag]);
      expect(isUpdatedObserver1, isFalse);
      expect(isUpdatedObserver2, isTrue);
    });

    test(
        "When many StateBuilder with the same tag,  add observer with the provided tag",
        () {
      final myWidget1 = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final observer2 = StatesRebuilderListener2();

      final splitAndAdd1 = SplitAndAddObserver(myWidget1, observer);
      final splitAndAdd2 = SplitAndAddObserver(myWidget2, observer2);

      expect(splitAndAdd1.tag.length, equals(1));
      expect(splitAndAdd1.tag[0], equals("myTag"));
      expect(splitAndAdd1.defaultTag, startsWith("myTag"));

      expect(splitAndAdd2.tag.length, equals(1));
      expect(splitAndAdd2.tag[0], startsWith("myTag"));
      expect(splitAndAdd2.defaultTag, startsWith("myTag"));
    });

    test("When many StateBuilder with the same tag,  rebuildState Works", () {
      final myWidget1 = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final observer2 = StatesRebuilderListener2();

      final splitAndAdd1 = SplitAndAddObserver(myWidget1, observer);
      final splitAndAdd2 = SplitAndAddObserver(myWidget2, observer2);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;
      vm.rebuildStates();
      expect(isUpdatedObserver1, isTrue);
      expect(isUpdatedObserver2, isTrue);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;

      vm.rebuildStates(["myTag"]);
      expect(isUpdatedObserver1, isTrue);
      expect(isUpdatedObserver2, isTrue);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;

      vm.rebuildStates([splitAndAdd1.defaultTag]);
      expect(isUpdatedObserver1, isTrue);
      expect(isUpdatedObserver2, isTrue);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;

      vm.rebuildStates([splitAndAdd2.defaultTag]);
      expect(isUpdatedObserver1, isTrue);
      expect(isUpdatedObserver2, isTrue);
    });

    test(
        "with no tag is provided, when rebuildStates is called without arguments or with tagID, it will rebuild",
        () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      isUpdatedObserver1 = false;
      vm.rebuildStates();
      expect(isUpdatedObserver1, isTrue);

      isUpdatedObserver1 = false;
      vm.rebuildStates([splitAndAdd.defaultTag]);
      expect(isUpdatedObserver1, isTrue);
    });

    test("When one tag is provided, add to observer with this tag", () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      expect(splitAndAdd.tag[0], equals("myTag"));
      expect(splitAndAdd.defaultTag, startsWith("myTag"));
    });

    test(
        "with one tag, when rebuildStates is called without arguments or with this tag or with tagID, it will rebuild",
        () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      isUpdatedObserver1 = false;
      vm.rebuildStates();
      expect(isUpdatedObserver1, isTrue);

      isUpdatedObserver1 = false;
      vm.rebuildStates(["myTag"]);
      expect(isUpdatedObserver1, isTrue);

      isUpdatedObserver1 = false;
      vm.rebuildStates([splitAndAdd.defaultTag]);
      expect(isUpdatedObserver1, isTrue);
    });

    test(
        "When a list of tags are provided, add observer with these tags, enums work",
        () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        tag: ["myTag1", MyEnum.tag],
        builder: (_, __) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      expect(splitAndAdd.tag.length, equals(3));
      expect(splitAndAdd.tag[0], equals("myTag1"));
      expect(splitAndAdd.tag[1], equals(MyEnum.tag.toString()));
      expect(splitAndAdd.defaultTag, startsWith("#@deFau_Lt"));
    });

    test(
        "with many tags, when rebuildStates is called without arguments or with any tag or with any tagID, it will rebuild",
        () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        tag: ["myTag1", MyEnum.tag],
        builder: (_, __) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      isUpdatedObserver1 = false;
      vm.rebuildStates();
      expect(isUpdatedObserver1, isTrue);

      isUpdatedObserver1 = false;
      vm.rebuildStates(["myTag1"]);
      expect(isUpdatedObserver1, isTrue);

      vm.rebuildStates([MyEnum.tag]);
      expect(isUpdatedObserver1, isTrue);

      isUpdatedObserver1 = false;
      print(splitAndAdd.tag);
      vm.rebuildStates([splitAndAdd.defaultTag]);
      expect(isUpdatedObserver1, isTrue);
    });

    test("With many viewModels works, observer are added to these models", () {
      final vm2 = ViewModel();
      final observer2 = StatesRebuilderListener2();

      final myWidget1 = StateBuilder(
        viewModels: [vm],
        tag: "myTag_VM1",
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm2],
        tag: "myTag_VM2",
        builder: (_, String tagID) => null,
      );

      final splitAndAdd1 = SplitAndAddObserver(myWidget1, observer);
      final splitAndAdd2 = SplitAndAddObserver(myWidget2, observer2);

      expect(splitAndAdd1.tag[0], equals("myTag_VM1"));
      expect(splitAndAdd1.defaultTag, startsWith("myTag_VM1"));

      expect(splitAndAdd2.tag[0], equals("myTag_VM2"));
      expect(splitAndAdd2.defaultTag, startsWith("myTag_VM2"));
    });

    test("With many viewModels works, rebuildStates works for each model", () {
      final vm2 = ViewModel();
      final observer2 = StatesRebuilderListener2();

      final myWidget1 = StateBuilder(
        viewModels: [vm],
        tag: "myTag_VM1",
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm2],
        tag: "myTag_VM2",
        builder: (_, String tagID) => null,
      );

      SplitAndAddObserver(myWidget1, observer);
      SplitAndAddObserver(myWidget2, observer2);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;
      vm.rebuildStates();
      expect(isUpdatedObserver1, isTrue);
      expect(isUpdatedObserver2, isFalse);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;

      vm.rebuildStates(["myTag_VM1"]);
      expect(isUpdatedObserver1, isTrue);
      expect(isUpdatedObserver2, isFalse);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;
      vm2.rebuildStates();
      expect(isUpdatedObserver1, isFalse);
      expect(isUpdatedObserver2, isTrue);

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;

      vm2.rebuildStates(["myTag_VM2"]);
      expect(isUpdatedObserver1, isFalse);
      expect(isUpdatedObserver2, isTrue);
    });
  });

  group("removeFromObserver : ", () {
    test("When no tag is provided, remove observer with default tag works", () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);
      expect(vm.observers().length, equals(1));
      splitAndAdd.removeFromObserver();
      expect(vm.observers().length, equals(0));
    });

    test("When one tag is provided, remove observer works", () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);
      expect(vm.observers().length, equals(1));
      expect(vm.observers()[splitAndAdd.tag[0]].length, equals(1));
      splitAndAdd.removeFromObserver();
      expect(vm.observers().length, equals(0));
    });

    test("When a list of tags are provided, remove observer works", () {
      final myWidget = StateBuilder(
        viewModels: [vm],
        tag: ["myTag1", MyEnum.tag],
        builder: (_, __) => null,
      );

      final splitAndAdd = SplitAndAddObserver(myWidget, observer);

      expect(vm.observers().length, equals(3));
      expect(vm.observers()[splitAndAdd.tag[0]].length, equals(1));
      splitAndAdd.removeFromObserver();
      expect(vm.observers().length, equals(0));
    });

    test("With many viewModels provided , remove observer works", () {
      final vm2 = ViewModel();
      final observer2 = StatesRebuilderListener2();

      final myWidget1 = StateBuilder(
        viewModels: [vm],
        tag: "myTag_VM1",
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm2],
        tag: "myTag_VM2",
        builder: (_, String tagID) => null,
      );

      final splitAndAdd1 = SplitAndAddObserver(myWidget1, observer);
      final splitAndAdd2 = SplitAndAddObserver(myWidget2, observer2);

      expect(vm.observers().length, equals(1));
      expect(vm.observers()[splitAndAdd1.tag[0]].length, equals(1));
      splitAndAdd1.removeFromObserver();
      expect(vm.observers().length, equals(0));

      expect(vm2.observers().length, equals(1));
      expect(vm2.observers()[splitAndAdd2.tag[0]].length, equals(1));
      splitAndAdd2.removeFromObserver();
      expect(vm2.observers().length, equals(0));
    });

    test("When no tag is provided, remove observer works", () {
      final myWidget1 = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm],
        builder: (_, String tagID) => null,
      );

      final observer2 = StatesRebuilderListener2();

      final splitAndAdd1 = SplitAndAddObserver(myWidget1, observer);
      final splitAndAdd2 = SplitAndAddObserver(myWidget2, observer2);
      print(vm.observers());
      expect(vm.observers().length, equals(2));
      expect(vm.observers()[splitAndAdd1.tag[0]].length, equals(1));
      expect(vm.observers()[splitAndAdd2.tag[0]].length, equals(1));

      splitAndAdd1.removeFromObserver();
      expect(vm.observers().length, equals(1));
      expect(vm.observers()[splitAndAdd2.tag[0]].length, equals(1));

      splitAndAdd2.removeFromObserver();
      expect(vm.observers().length, equals(0));
    });

    test("When many StateBuilder share the same tag, remove observer works",
        () {
      final myWidget1 = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final myWidget2 = StateBuilder(
        viewModels: [vm],
        tag: "myTag",
        builder: (_, String tagID) => null,
      );

      final observer2 = StatesRebuilderListener2();

      final splitAndAdd1 = SplitAndAddObserver(myWidget1, observer);
      final splitAndAdd2 = SplitAndAddObserver(myWidget2, observer2);

      expect(vm.observers().length, equals(1));
      expect(vm.observers()[splitAndAdd1.tag[0]].length, equals(2));
      expect(vm.observers()[splitAndAdd2.tag[0]].length, equals(2));

      splitAndAdd1.removeFromObserver();
      expect(vm.observers().length, equals(1));
      expect(vm.observers()[splitAndAdd2.tag[0]].length, equals(1));

      splitAndAdd2.removeFromObserver();
      expect(vm.observers().length, equals(0));
    });
  });
}

class ViewModel extends StatesRebuilder {}

bool isUpdatedObserver1 = false;
bool isUpdatedObserver2 = false;

class StatesRebuilderListener1 implements ListenerOfStatesRebuilder {
  @override
  bool update([void Function(BuildContext) afterRebuildCallBack]) {
    isUpdatedObserver1 = true;
    return true;
  }
}

class StatesRebuilderListener2 implements ListenerOfStatesRebuilder {
  @override
  bool update([void Function(BuildContext) afterRebuildCallBack]) {
    isUpdatedObserver2 = true;
    return true;
  }
}

enum MyEnum { tag }

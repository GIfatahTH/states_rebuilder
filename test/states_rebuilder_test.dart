import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';
import 'package:states_rebuilder/src/common.dart';

void main() {
  group("addObserver : ", () {
    test("Do not add observer if tag, tagID or observer is null", () {
      final vm = ViewModel();
      final observer1 = StatesRebuilderListener1();
      vm.addObserver(
        tag: "tag1",
        tagID: "tag1ID_1",
        observer: null,
      );
      expect(vm.observers().length, equals(0));

      vm.addObserver(
        tag: "tag1",
        tagID: null,
        observer: observer1,
      );
      expect(vm.observers().length, equals(0));

      vm.addObserver(
        tag: null,
        tagID: "tag1ID",
        observer: observer1,
      );
      expect(vm.observers().length, equals(0));
    });

    test("addObserver works", () {
      final vm = ViewModel();
      final observer1 = StatesRebuilderListener1();

      expect(vm.observers().length, equals(0));

      vm.addObserver(
        tag: "tag1",
        tagID: "tag1ID_1",
        observer: observer1,
      );

      expect(vm.observers().length, equals(1));
      expect(vm.observers()["tag1"].length, equals(1));
      expect(vm.observers()["tag1"]["tag1ID_1"].hashCode == observer1.hashCode,
          isTrue);

      vm.addObserver(
        tag: "tag1",
        tagID: "tag1ID_2",
        observer: StatesRebuilderListener1(),
      );

      expect(vm.observers().length, equals(1));
      expect(vm.observers()["tag1"].length, equals(2));
      expect(vm.observers()["tag1"]["tag1ID_2"].hashCode == observer1.hashCode,
          isFalse);

      vm.addObserver(
        tag: "tag2",
        tagID: "tag2ID_1",
        observer: StatesRebuilderListener1(),
      );

      expect(vm.observers().length, equals(2));
      expect(vm.observers()["tag1"].length, equals(2));
      expect(vm.observers()["tag2"].length, equals(1));

      final observer2 = StatesRebuilderListener1();
      vm.addObserver(
        tag: "tag2",
        tagID: "tag2ID_2",
        observer: observer2,
      );

      expect(vm.observers().length, equals(2));
      expect(vm.observers()["tag1"].length, equals(2));
      expect(vm.observers()["tag2"].length, equals(2));
      expect(vm.observers()["tag2"]["tag2ID_2"].hashCode == observer2.hashCode,
          isTrue);
    });
  });

  group("removeObserver : ", () {
    test("remove non existing tag throws exception", () {
      final vm = ViewModel();

      expect(
          () => vm.removeObserver(
                tag: "tag1",
                tagID: "tag1ID_1",
              ),
          throwsException);
    });

    test("remove empty tags throws exception", () {
      final vm = ViewModel();
      vm.addObserver(
        tag: "tag1",
        tagID: null,
        observer: null,
      );
      expect(
          () => vm.removeObserver(
                tag: "tag1",
                tagID: "tag1ID_1",
              ),
          throwsException);
    });

    test("removeObserver works", () {
      final vm = ViewModel();
      final observer1 = StatesRebuilderListener1();

      expect(vm.observers().length, equals(0));

      vm.addObserver(
        tag: "tag1",
        tagID: "tag1ID_1",
        observer: observer1,
      );

      vm.addObserver(
        tag: "tag1",
        tagID: "tag1ID_2",
        observer: StatesRebuilderListener1(),
      );
      vm.addObserver(
        tag: "tag2",
        tagID: "tag2ID_1",
        observer: StatesRebuilderListener1(),
      );

      bool isCleaner = false;
      String statesRebuilderCleanerTag;
      vm.cleaner(() {
        isCleaner = true;
      });

      vm.statesRebuilderCleaner = (String tag) {
        statesRebuilderCleanerTag = tag;
      };

      vm.removeObserver(
        tag: "tag1",
        tagID: "tag1ID_1",
      );

      expect(vm.observers().length, equals(2));
      expect(isCleaner, isFalse);
      expect(statesRebuilderCleanerTag, "tag1ID_1");

      vm.removeObserver(
        tag: "tag1",
        tagID: "tag1ID_2",
      );

      expect(vm.observers().length, equals(1));
      expect(isCleaner, isFalse);
      expect(statesRebuilderCleanerTag, "tag1");

      vm.removeObserver(
        tag: "tag2",
        tagID: "tag2ID_1",
      );

      expect(vm.observers().length, equals(0));
      expect(isCleaner, isTrue);
      expect(statesRebuilderCleanerTag, isNull);
    });
  });

  group("rebuildStates : ", () {
    ViewModel vm;
    ListenerOfStatesRebuilder observer1;
    ListenerOfStatesRebuilder observer2;
    ListenerOfStatesRebuilder observer3;
    setUp(() {
      vm = ViewModel();
      observer1 = StatesRebuilderListener1();
      observer2 = StatesRebuilderListener2();
      observer3 = StatesRebuilderListener3();

      vm.addObserver(
        tag: 'tag1',
        tagID: 'tag1ID_1',
        observer: observer1,
      );

      vm.addObserver(
        tag: 'tag1',
        tagID: 'tag1ID_2',
        observer: observer2,
      );

      vm.addObserver(
        tag: 'tag2',
        tagID: 'tag2ID',
        observer: observer3,
      );

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;
      isUpdatedObserver3 = false;
    });
    test("empty observers throw exception", () {
      expect(() {
        vm = ViewModel();
        vm.rebuildStates();
      }, throwsException);
    });

    test("empty observers does not throw exception using hasObserver", () {
      expect(() {
        vm = ViewModel();
        if (vm.hasState) vm.rebuildStates();
      }, isNot(throwsException));
    });

    test("when called with no argument is will rebuild all observers", () {
      vm.rebuildStates();
      expect(isUpdatedObserver1 && isUpdatedObserver2 && isUpdatedObserver3,
          isTrue);
    });

    test("when called with one tag, it will rebuild all observer with the tag ",
        () {
      vm.rebuildStates(['tag1']);
      expect(isUpdatedObserver1 && isUpdatedObserver2 && isUpdatedObserver3,
          isFalse);
      expect(isUpdatedObserver1 && isUpdatedObserver2, isTrue);
    });

    test(
        "when called with the form ('tag1' + splitter + 'tag1ID_1') , it will rebuild one observer with the tagID ",
        () {
      vm.rebuildStates(['tag1' + splitter + 'tag1ID_1']);
      expect(isUpdatedObserver1 && isUpdatedObserver2 && isUpdatedObserver3,
          isFalse);
      expect(isUpdatedObserver1 && isUpdatedObserver2, isFalse);
      expect(isUpdatedObserver1, isTrue);
    });
  });

  test(
      "when called with the form ('tag1' + splitter + 'tag1ID_1') , it will rebuild one observer with the tagID ",
      () {});
}

class ViewModel extends StatesRebuilder {}

bool isUpdatedObserver1 = false;
bool isUpdatedObserver2 = false;
bool isUpdatedObserver3 = false;

class StatesRebuilderListener1 implements ListenerOfStatesRebuilder {
  @override
  void update() {
    isUpdatedObserver1 = true;
  }
}

class StatesRebuilderListener2 implements ListenerOfStatesRebuilder {
  @override
  void update() {
    isUpdatedObserver2 = true;
  }
}

class StatesRebuilderListener3 implements ListenerOfStatesRebuilder {
  @override
  void update() {
    isUpdatedObserver3 = true;
  }
}

enum EnumTags { tag1 }

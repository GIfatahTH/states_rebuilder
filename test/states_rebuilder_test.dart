// refactor : remove tagID and change blocs to models

// add initialStateStatus

// remove getNewAsModel and add onRebuildCallBack, asNewInstanceModel and resetStateStatus

// add catchError and onSetState

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

void main() {
  group("addObserver : ", () {
    test("Do not add observer if tag or observer is null", () {
      final vm = ViewModel();
      final observer1 = StatesRebuilderListener1();
      vm.addObserver(
        tag: "tag1",
        observer: null,
      );
      expect(vm.observers().length, equals(0));

      vm.addObserver(
        tag: null,
        observer: observer1,
      );
      expect(vm.observers().length, equals(0));

      vm.addObserver(
        tag: "tag1",
        observer: observer1,
      );
      expect(vm.observers().length, equals(1));
    });

    test("addObserver works", () {
      final vm = ViewModel();
      final observer1 = StatesRebuilderListener1();

      expect(vm.observers().length, equals(0));

      vm.addObserver(
        tag: "tag1",
        observer: observer1,
      );

      expect(vm.observers().length, equals(1));

      vm.addObserver(
        tag: "tag1",
        observer: StatesRebuilderListener1(),
      );

      expect(vm.observers().length, equals(1));

      vm.addObserver(
        tag: "tag2",
        observer: StatesRebuilderListener1(),
      );

      expect(vm.observers().length, equals(2));

      final observer2 = StatesRebuilderListener1();
      vm.addObserver(
        tag: "tag2",
        observer: observer2,
      );

      expect(vm.observers().length, equals(2));
    });
  });

  group("removeObserver : ", () {
    test("remove non existing tag throws exception", () {
      final vm = ViewModel();

      expect(() => vm.removeObserver(tag: "tag1", observer: null),
          throwsException);
    });

    test("remove empty tags throws exception", () {
      final vm = ViewModel();
      vm.addObserver(
        tag: "tag1",
        observer: null,
      );
      expect(
        () => vm.removeObserver(tag: "", observer: null),
        throwsException,
      );
    });

    test("removeObserver works", () {
      final vm = ViewModel();
      final observer1 = StatesRebuilderListener1();
      final observer2 = StatesRebuilderListener1();
      final observer3 = StatesRebuilderListener1();

      expect(vm.observers().length, equals(0));

      vm.addObserver(
        tag: "tag1",
        observer: observer1,
      );

      vm.addObserver(
        tag: "tag1",
        observer: observer2,
      );
      vm.addObserver(
        tag: "tag2",
        observer: observer3,
      );

      bool isCleaner = false;
      String statesRebuilderCleanerTag = "before";
      vm.cleaner(() {
        isCleaner = true;
      });

      vm.statesRebuilderCleaner = (String tag) {
        statesRebuilderCleanerTag = tag;
      };

      vm.removeObserver(
        tag: "tag1",
        observer: observer1,
      );

      expect(vm.observers().length, equals(2));
      expect(isCleaner, isFalse);
      expect(statesRebuilderCleanerTag, "before");

      vm.removeObserver(
        tag: "tag1",
        observer: observer2,
      );

      expect(vm.observers().length, equals(1));
      expect(isCleaner, isFalse);
      expect(statesRebuilderCleanerTag, "tag1");

      vm.removeObserver(
        tag: "tag2",
        observer: observer3,
      );
      expect(vm.observers().length, equals(0));
      expect(isCleaner, isTrue);
      expect(statesRebuilderCleanerTag, isNull);

      vm.addObserver(
        tag: "tag1",
        observer: observer1,
      );
      vm.addObserver(
        tag: "tag2",
        observer: observer2,
      );

      isCleaner = false;
      vm.cleaner(() {
        isCleaner = true;
      });

      vm.statesRebuilderCleaner = (String tag) {
        statesRebuilderCleanerTag = tag;
      };
      vm.removeObserver(
        tag: null,
        observer: null,
      );
      expect(isCleaner, isTrue);
      expect(statesRebuilderCleanerTag, isNull);
    });
  });

  group("rebuildStates : ", () {
    ViewModel vm;
    ObserverOfStatesRebuilder observer1;
    ObserverOfStatesRebuilder observer2;
    ObserverOfStatesRebuilder observer3;
    setUp(() {
      vm = ViewModel();
      observer1 = StatesRebuilderListener1();
      observer2 = StatesRebuilderListener2();
      observer3 = StatesRebuilderListener3();

      vm.addObserver(
        tag: 'tag1',
        observer: observer1,
      );

      vm.addObserver(
        tag: 'tag1',
        observer: observer2,
      );

      vm.addObserver(
        tag: 'tag2',
        observer: observer3,
      );

      isUpdatedObserver1 = false;
      isUpdatedObserver2 = false;
      isUpdatedObserver3 = false;
      orderOfRebuild = [];
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
        if (vm.hasObservers) vm.rebuildStates();
      }, isNot(throwsException));
    });

    test("when called with no argument is will rebuild all observers", () {
      vm.rebuildStates();
      expect(isUpdatedObserver1 && isUpdatedObserver2 && isUpdatedObserver3,
          isTrue);
    });

    test("last add first rebuild. Case observers", () {
      vm.rebuildStates();
      expect(orderOfRebuild, ['3', '2', '1']);
    });

    test("when called with one tag, it will rebuild all observer with the tag ",
        () {
      vm.rebuildStates(['tag1']);
      expect(isUpdatedObserver1 && isUpdatedObserver2 && isUpdatedObserver3,
          isFalse);
      expect(isUpdatedObserver1 && isUpdatedObserver2, isTrue);
    });
  });
}

class ViewModel extends StatesRebuilder {}

bool isUpdatedObserver1 = false;
bool isUpdatedObserver2 = false;
bool isUpdatedObserver3 = false;

List<String> orderOfRebuild = [];

class StatesRebuilderListener1 implements ObserverOfStatesRebuilder {
  @override
  bool update(
      [void Function(BuildContext) afterRebuildCallBack, bool afterRebuild]) {
    isUpdatedObserver1 = true;
    orderOfRebuild.add("1");
    return true;
  }
}

class StatesRebuilderListener2 implements ObserverOfStatesRebuilder {
  @override
  bool update(
      [void Function(BuildContext) afterRebuildCallBack, bool afterRebuild]) {
    isUpdatedObserver2 = true;
    orderOfRebuild.add("2");
    return true;
  }
}

class StatesRebuilderListener3 implements ObserverOfStatesRebuilder {
  @override
  bool update(
      [void Function(BuildContext) afterRebuildCallBack, bool afterRebuild]) {
    isUpdatedObserver3 = true;
    orderOfRebuild.add("3");
    return true;
  }
}

enum EnumTags { tag1 }

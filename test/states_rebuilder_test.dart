import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';
import 'package:states_rebuilder/src/states_rebuilder_debug.dart';

void main() {
  Model model;
  setUp(() {
    model = Model();
  });

  test(
    'should add and remove observer : assert that tag is not null and observer is not null',
    () {
      //assert tag != null
      expect(
        () {
          model.addObserver(observer: ObserverWidget());
        },
        throwsAssertionError,
      );

      //assert observer != null
      expect(
        () {
          model.addObserver(tag: 'MyTag');
        },
        throwsAssertionError,
      );
    },
  );

  test(
    'should add and remove observer',
    () {
      expect(model.observers().length, equals(0));
      final observer1 = ObserverWidget();
      final observer2 = ObserverWidget();
      final observer3 = ObserverWidget();
      //add observer1 with 'MyTag1'
      model.addObserver(observer: observer1, tag: 'MyTag1');
      expect(model.observers().length, equals(1));

      //add observer2 with 'MyTag1'
      model.addObserver(observer: observer2, tag: 'MyTag1');
      expect(model.observers().length, equals(1));
      expect(model.observers()['MyTag1'].length, equals(2));

      //add observer2 with 'MyTag'
      model.addObserver(observer: observer3, tag: 'MyTag3');
      expect(model.observers().length, equals(2));
      expect(model.observers()['MyTag1'].length, equals(2));

      //remove observer1 with MyTag1
      model.removeObserver(observer: observer1, tag: 'MyTag1');
      expect(model.observers().length, equals(2));
      expect(model.observers()['MyTag1'].length, equals(1));

      //remove observer2 with MyTag1
      model.removeObserver(observer: observer2, tag: 'MyTag1');
      expect(model.observers().length, equals(1));
      expect(model.observers()['MyTag1'], isNull);

      //remove observer3 with MyTag3
      model.removeObserver(observer: observer3, tag: 'MyTag3');
      expect(model.observers().isEmpty, isTrue);
      expect(model.observers()['MyTag3'], isNull);
    },
  );

  test(
    'removing non exciting tag should throw',
    () {
      expect(
        () {
          model.removeObserver(observer: ObserverWidget(), tag: 'MyTag1');
        },
        throwsException,
      );
    },
  );

  test(
    'should not rebuildState of non existing tag',
    () {
      final observer1 = ObserverWidget();
      model.addObserver(observer: observer1, tag: 'tag1');
      model.rebuildStates(['nonExistingTag']);
      expect(observer1.numOfUpdates, equals(0));
    },
  );

  test(
    'should rebuild all observers if tag is null',
    () {
      final observer1 = ObserverWidget();
      final observer2 = ObserverWidget();
      final observer3 = ObserverWidget();

      //add observers
      model.addObserver(observer: observer1, tag: 'tag1');
      model.addObserver(observer: observer2, tag: 'tag1');
      model.addObserver(observer: observer3, tag: 'tag3');

      //notify observers with no tag
      model.rebuildStates();

      //all observers will rebuild.
      expect(observer1.numOfUpdates, equals(1));
      expect(observer2.numOfUpdates, equals(1));
      expect(observer3.numOfUpdates, equals(1));
    },
  );

  test(
    'should rebuild all observers filtered with tag',
    () {
      final observer1 = ObserverWidget();
      final observer2 = ObserverWidget();
      final observer3 = ObserverWidget();

      //add observers
      model.addObserver(observer: observer1, tag: 'tag1');
      model.addObserver(observer: observer2, tag: 'tag1');
      model.addObserver(observer: observer3, tag: 'tag3');

      //notify observers with tag1
      model.rebuildStates(['tag1']);

      //observers with tag1 will rebuild.
      expect(observer1.numOfUpdates, equals(1));
      expect(observer2.numOfUpdates, equals(1));
      expect(observer3.numOfUpdates, equals(0));

      //notify observers with tag3.
      model.rebuildStates(['tag3']);

      //observers with tag3 will rebuild.
      expect(observer1.numOfUpdates, equals(1));
      expect(observer2.numOfUpdates, equals(1));
      expect(observer3.numOfUpdates, equals(1));

      //notify observers with tag1 and tag3.
      model.rebuildStates(['tag1', 'tag3']);

      //observers with tag1 and tag3 will rebuild.
      expect(observer1.numOfUpdates, equals(2));
      expect(observer2.numOfUpdates, equals(2));
      expect(observer3.numOfUpdates, equals(2));
    },
  );

  test(
    'should rebuild all observers filtered with Enum type tags',
    () {
      final observer1 = ObserverWidget();
      final observer2 = ObserverWidget();
      final observer3 = ObserverWidget();

      //add observers
      model.addObserver(observer: observer1, tag: Tags.tag1.toString());
      model.addObserver(observer: observer2, tag: Tags.tag1.toString());
      model.addObserver(observer: observer3, tag: Tags.tag3.toString());

      //notify observers with Tags.tag1
      model.rebuildStates([Tags.tag1]);

      //observers with Tags.tag1 will rebuild.
      expect(observer1.numOfUpdates, equals(1));
      expect(observer2.numOfUpdates, equals(1));
      expect(observer3.numOfUpdates, equals(0));
    },
  );

  test(
    'should not throw if filtered with nonexisting tag',
    () {
      final observer1 = ObserverWidget();

      //add observers
      model.addObserver(observer: observer1, tag: 'tag1');

      //notify observers with tag1
      model.rebuildStates(['nonExistingTag']);

      //no observer will be rebuilt.
      expect(observer1.numOfUpdates, equals(0));
    },
  );

  test(
    'should throw if calling rebuildStates when no observer is subscribed',
    () {
      expect(() => model.rebuildStates(), throwsException);
    },
  );

  test(
    'should call onSetState',
    () {
      final observer1 = ObserverWidget();

      //add observers
      model.addObserver(observer: observer1, tag: 'tag1');

      int numberOfOnSetStateCall = 0;

      final onSetState = (context) {
        numberOfOnSetStateCall++;
      };

      //notify observer with null tag
      model.rebuildStates(null, onSetState);
      expect(numberOfOnSetStateCall, equals(1));

      //notify observer with tag1
      model.rebuildStates(['tag1'], onSetState);
      expect(numberOfOnSetStateCall, equals(2));

      //notify observer with nonExistingTag
      model.rebuildStates(['nonExistingTag'], onSetState);
      expect(numberOfOnSetStateCall, equals(2));
    },
  );

  test(
    'should call onSetState only once for list of observers',
    () {
      final observer1 = ObserverWidget();
      final observer2 = ObserverWidget();
      final observer3 = ObserverWidget();

      //add observers
      model.addObserver(observer: observer1, tag: 'tag1');
      model.addObserver(observer: observer2, tag: 'tag1');
      model.addObserver(observer: observer3, tag: 'tag3');

      int numberOfOnSetStateCall = 0;

      final onSetState = (context) {
        numberOfOnSetStateCall++;
      };

      //notify observer with null tag
      model.rebuildStates(null, onSetState);
      expect(numberOfOnSetStateCall, equals(1));

      numberOfOnSetStateCall = 0;
      //notify observer with tag1
      model.rebuildStates(['tag1'], onSetState);
      expect(numberOfOnSetStateCall, equals(1));

      numberOfOnSetStateCall = 0;
      //notify observer with tag1
      model.rebuildStates(['tag3'], onSetState);
      expect(numberOfOnSetStateCall, equals(1));
    },
  );

  test(
    'should call cleaner callback',
    () {
      expect(model.observers().length, equals(0));
      final observer1 = ObserverWidget();
      final observer2 = ObserverWidget();
      final observer3 = ObserverWidget();
      model.addObserver(observer: observer1, tag: 'tag1');
      model.addObserver(observer: observer2, tag: 'tag1');
      model.addObserver(observer: observer3, tag: 'tag3');

      int numberOfCleanerCall = 0;

      model.cleaner(() {
        numberOfCleanerCall++;
      });

      model.removeObserver(observer: observer3, tag: 'tag3');
      expect(numberOfCleanerCall, equals(0));
      model.removeObserver(observer: observer1, tag: 'tag1');
      expect(numberOfCleanerCall, equals(0));
      model.removeObserver(observer: observer2, tag: 'tag1');
      expect(numberOfCleanerCall, equals(1));
    },
  );

  test(
    'should StatesRebuilderDebug.printObservers works',
    () {
      final observer1 = ObserverWidget();
      final observer2 = ObserverWidget();
      final observer3 = ObserverWidget();

      //add observers
      model.addObserver(observer: observer1, tag: 'tag1');
      model.addObserver(observer: observer2, tag: 'tag1');
      model.addObserver(observer: observer3, tag: 'tag3');
      final text = StatesRebuilderDebug.printObservers(model);
      expect(text, contains('Number of observers subscribed to Model is: 2'));
      expect(text, contains('tag3 : [ObserverWidget'));
      expect(text, contains('tag1 : [ObserverWidget'));
    },
  );
}

class Model extends StatesRebuilder {
  int count;
  increment() {}
}

class ObserverWidget extends ObserverOfStatesRebuilder {
  int numOfUpdates = 0;
  @override
  bool update([void Function(BuildContext) onSetState]) {
    numOfUpdates++;
    if (onSetState != null) {
      onSetState(null);
    }
    return true;
  }
}

enum Tags { tag1, tag2, tag3 }

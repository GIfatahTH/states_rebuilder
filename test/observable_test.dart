import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('should rebuild from Service1, case one observer',
      (WidgetTester tester) async {
    int rebuildCounter = 0;
    await tester.pumpWidget(
      Injector<ViewModel1>(
        models: [
          () => Service1(),
          () => ViewModel1(),
        ],
        builder: (context, model) {
          rebuildCounter++;
          return Container();
        },
      ),
    );

    final service1 = Injector.get<Service1>();

    expect(rebuildCounter, equals(1));
    service1.notifyObserver();
    await tester.pump();
    expect(rebuildCounter, equals(2));
  });

  testWidgets('should rebuild from Service1, case many observers',
      (WidgetTester tester) async {
    int rebuildCounter1 = 0;
    int rebuildCounter2 = 0;
    int rebuildCounter3 = 0;
    await tester.pumpWidget(
      Column(
        children: <Widget>[
          Injector<ViewModel1>(
            models: [
              () => Service1(),
              () => ViewModel1(),
            ],
            builder: (context, model) {
              rebuildCounter1++;
              return Container();
            },
          ),
          Injector<ViewModel2>(
            models: [() => ViewModel2()],
            builder: (context, model) {
              rebuildCounter2++;
              return StateBuilder(
                viewModels: [ViewModel2()],
                tag: 'myTag',
                builder: (context, tagID) {
                  rebuildCounter3++;
                  return Container();
                },
              );
            },
          ),
        ],
      ),
    );

    final service1 = Injector.get<Service1>();

    expect(rebuildCounter1, equals(1));
    expect(rebuildCounter2, equals(1));
    expect(rebuildCounter3, equals(1));

    service1.notifyObserver();
    await tester.pump();
    expect(rebuildCounter1, equals(2));
    expect(rebuildCounter2,
        equals(1)); //not rebuild, statesRebuilder is called with tag;
    expect(rebuildCounter3, equals(2)); //Rebuilds, it has the tag:
  });
}

class ViewModel1 extends StatesRebuilder {
  final service1 = Injector.get<Service1>();
  ViewModel1() {
    service1.addObserver(this);
  }
}

class ViewModel2 extends StatesRebuilder {
  final service1 = Injector.get<Service1>();
  ViewModel2() {
    service1.addObserver(this, ["myTag"]);
  }
}

class Service1 extends ObservableService {
  String message = "I am Service1";
  notifyObserver() {
    rebuildStates();
  }
}

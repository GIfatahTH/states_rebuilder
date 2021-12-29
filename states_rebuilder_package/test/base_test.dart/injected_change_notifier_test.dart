import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'WHEN the injected state is ChangeNotifier'
    'THEN the model will listen to it and dispose it when it is disposed',
    (tester) async {
      final model = RM.inject(
        () {
          return _Model();
        },
        debugPrintWhenNotifiedPreMessage: '',
      );
      final switcher = true.inj();
      final widget = OnReactive(() {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: switcher.state
              ? Text(
                  '${model.state.counter}',
                )
              : Container(),
        );
      });
      await tester.pumpWidget(widget);
      expect(model.hasData, isTrue);
      expect(find.text('0'), findsOneWidget);
      model.state.increment();
      await tester.pump();
      expect(model.hasData, isTrue);
      expect(find.text('1'), findsOneWidget);
      //
      switcher.toggle();
      await tester.pump();
      expect(model.state.counter, 0);
      expect(model.hasData, isTrue);
    },
  );
}

class _Model extends ChangeNotifier {
  int counter = 0;

  void increment() {
    counter++;
    notifyListeners();
  }
}

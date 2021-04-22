import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//used for Test,
//It holds the stream emitted data.
int? streamData;

final injectedStream = RM.injectStream(
  () => Stream<int>.periodic(
    Duration(seconds: 1),
    (data) {
      streamData = data;
      return data;
    },
  ),
  initialState: 0,
);

//Use StatefulWidget
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //variable used to hide the injected stream widget observer
  bool _isHidden = false;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          if (!_isHidden)
            On.data(
              () => Text('${injectedStream.state}'),
            ).listenTo(injectedStream)
          else
            Text('Injected stream is disposed'),
          ElevatedButton(
            child: Text('Toggle Hide'),
            onPressed: () => setState(() => _isHidden = !_isHidden),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets(
    'Should close stream when injected model is disposed',
    (tester) async {
      await tester.pumpWidget(MyApp());
      //Initial value of stream is 0
      expect(find.text('0'), findsOneWidget);
      expect(streamData, isNull);

      //after 1 second emitting 0
      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(streamData, 0);

      //after another 1 second emitting 1
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(streamData, 1);

      //hide injected stream widget observer
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      //
      expect(find.text('Injected stream is disposed'), findsOneWidget);
      //the stream does not emit any new value
      expect(streamData, 1);

      //after 1 second, the stream does not emit any new value
      await tester.pump(Duration(seconds: 1));
      expect(streamData, 1);

      //after another 1 second, the stream does not emit any new value
      await tester.pump(Duration(seconds: 1));
      expect(streamData, 1);

      //which means that the stream is disposed

      //If we toggle to display the injected stream,
      //an new stream subscription is established and we expect to see the value
      // null, 0, 1, and so on.
    },
  );

  //This is the same test as above. we can run all the test without any cross
  //interference between the two tests.
  testWidgets(
    'Should close stream when injected model is disposed 2',
    (tester) async {
      //We must reset the global variable streamData to null
      streamData = null;
      await tester.pumpWidget(MyApp());
      //Initial value of stream is 0
      expect(find.text('0'), findsOneWidget);
      expect(streamData, isNull);

      //after 1 second emitting 0
      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(streamData, 0);

      //after another 1 second emitting 1
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(streamData, 1);

      //hide injected stream widget observer
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      //
      expect(find.text('Injected stream is disposed'), findsOneWidget);
      //the stream does not emit any new value
      expect(streamData, 1);

      //after 1 second, the stream does not emit any new value
      await tester.pump(Duration(seconds: 1));
      expect(streamData, 1);

      //after another 1 second, the stream does not emit any new value
      await tester.pump(Duration(seconds: 1));
      expect(streamData, 1);

      //which means that the stream is disposed

      //If we toggle to display the injected stream,
      //an new stream subscription is established and we expect to see the value
      // null, 0, 1, and so on.
    },
  );
}

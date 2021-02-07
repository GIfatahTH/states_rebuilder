import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

class Route1 extends StatefulWidget {
  final dynamic data;
  Route1(this.data);

  @override
  _Route1State createState() => _Route1State();
}

class _Route1State extends State<Route1> {
  @override
  void dispose() {
    print('disposed route1');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data ?? ModalRoute.of(context)?.settings.arguments;
    return Text('Route1: $d');
  }
}

class Route2 extends StatefulWidget {
  final dynamic data;
  Route2(this.data);

  @override
  _Route2State createState() => _Route2State();
}

class _Route2State extends State<Route2> {
  @override
  void dispose() {
    print('disposed route2');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data ?? ModalRoute.of(context)?.settings.arguments;
    return Text('Route2: $d');
  }
}

final widget_ = MaterialApp(
  routes: {
    '/': (_) => Text('Home'),
    'Route1': (_) => Route1(null),
    'Route2': (_) => Route2(null),
    'Route3': (_) => Text('Route3'),
  },
  navigatorKey: RM.navigate.navigatorKey,
);

void main() {
  testWidgets('Assertiion not navigatorKey is not assigned', (tester) async {
    final widget = MaterialApp(
      routes: {
        '/': (_) => Text('Home'),
      },
    );
    await tester.pumpWidget(widget);
    expect(RM.context, null);
    expect(() => RM.navigate.toNamed('/'), throwsAssertionError);
  });

  testWidgets('navigate to', (tester) async {
    await tester.pumpWidget(widget_);
    expect(RM.context, isNotNull);
    expect(Navigator.of(RM.context!), isNotNull);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.to(Route1('data'));
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);
    //
    RM.navigate.toReplacement(Route2('data'), result: '');
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigate to named', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);
    //
    RM.navigate.toReplacementNamed('Route2', arguments: 'data', result: '');
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigate to remove until', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    //
    RM.navigate.toAndRemoveUntil(
      Route2('data'),
      untilRouteName: 'Route3',
    );
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    // print(find.text('Route2')); //TODO to verify in emulator
    // print(find.text('Route1'));
    // print(find.text('Home'));
    // print(find.text('Route3'));
    // //expect(find.text('Route2'), findsOneWidget);
  });

  testWidgets('navigate to remove all', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    //
    RM.navigate.toAndRemoveUntil(
      Route2('data'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    // print(find.text('Route2')); //TODO to verify in emulator
    // print(find.text('Route1'));
    // print(find.text('Home'));
    // print(find.text('Route3'));
    // //expect(find.text('Route2'), findsOneWidget);
  });

  testWidgets('navigate to named remove  until', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route2', arguments: 'data');
    await tester.pumpAndSettle();
    //
    RM.navigate.toNamedAndRemoveUntil(
      'Route3',
      arguments: 'data',
      untilRouteName: 'Route2',
    );
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    // print(find.text('Route2')); TODO to verify in emulator
    // print(find.text('Route1'));
    // print(find.text('Home'));
    // print(find.text('Route3'));
    // //expect(find.text('Route2'), findsOneWidget);
  });

  testWidgets('navigate to named remove  all', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route2', arguments: 'data');
    await tester.pumpAndSettle();
    //
    RM.navigate.toNamedAndRemoveUntil(
      'Route3',
      arguments: 'data',
    );
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    // print(find.text('Route2')); TODO to verify in emulator
    // print(find.text('Route1'));
    // print(find.text('Home'));
    // print(find.text('Route3'));
    // //expect(find.text('Route2'), findsOneWidget);
  });

  testWidgets('back unitll', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route2', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    RM.navigate.backUntil('Route1');
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('back and to named', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route2', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    RM.navigate.backAndToNamed('Route1', arguments: 'data', result: '');
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
  });

  testWidgets('to CupertinoDialog', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toCupertinoDialog(
      Dialog(
        child: Text(''),
      ),
      barrierDismissible: false,
    );
    await tester.pumpAndSettle();
    //
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('to BottomSheet', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toBottomSheet(
      Text('bottom sheet'),
      isDismissible: true,
      backgroundColor: Colors.red,
      barrierColor: Colors.black,
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      enableDrag: true,
      isScrollControlled: true,
      shape: BorderDirectional(),
    );
    await tester.pumpAndSettle();
    //
    expect(find.text('bottom sheet'), findsOneWidget);
  });

  testWidgets('to CupertinoModalPopup', (tester) async {
    await tester.pumpWidget(widget_);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toCupertinoModalPopup(
      Text('toCupertinoModalPopup'),
      semanticsDismissible: true,
      filter: ImageFilter.blur(),
    );
    await tester.pumpAndSettle();
    //
    expect(find.text('toCupertinoModalPopup'), findsOneWidget);
  });
}

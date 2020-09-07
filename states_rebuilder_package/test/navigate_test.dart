import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('should throw if no context is defined', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => Home(),
          '/PageOne': (_) => PageOne(),
          '/PageTwo': (_) => PageTwo(),
          '/PageThree': (_) => PageThree(),
        },
      ),
    );
    expect(find.byType(Home), findsOneWidget);
    expect(() => RM.navigate.to(PageOne()), throwsAssertionError);
  });

  testWidgets('navigate to and back', (tester) async {
    await tester.pumpWidget(NavigationApp());
    expect(find.byType(Home), findsOneWidget);

    RM.navigate.to(PageOne());
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.to(PageTwo());
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('navigate toNamed and back', (tester) async {
    await tester.pumpWidget(NavigationApp());
    expect(find.byType(Home), findsOneWidget);

    RM.navigate.toNamed('/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.toNamed('/PageTwo');
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('navigate toReplacement and back', (tester) async {
    await tester.pumpWidget(NavigationApp());
    expect(find.byType(Home), findsOneWidget);

    RM.navigate.to(PageOne());
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.toReplacement(PageTwo());
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('navigate toReplacementNamed  and back', (tester) async {
    await tester.pumpWidget(NavigationApp());
    expect(find.byType(Home), findsOneWidget);

    RM.navigate.toNamed('/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.toReplacementNamed('/PageTwo');
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('navigate toAndRemoveUntil and back', (tester) async {
    await tester.pumpWidget(NavigationApp());
    expect(find.byType(Home), findsOneWidget);

    RM.navigate.toNamed('/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.toNamed('/PageTwo');
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.toNamed('/PageThree');
    await tester.pumpAndSettle();
    expect(find.byType(PageThree), findsOneWidget);

    RM.navigate.toAndRemoveUntil(PageTwo(), untilRouteName: '/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('navigate toNamedAndRemoveUntil and back', (tester) async {
    await tester.pumpWidget(NavigationApp());
    expect(find.byType(Home), findsOneWidget);

    RM.navigate.toNamed('/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.toNamed('/PageTwo');
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.toNamed('/PageThree');
    await tester.pumpAndSettle();
    expect(find.byType(PageThree), findsOneWidget);

    RM.navigate.toNamedAndRemoveUntil('/PageTwo', untilRouteName: '/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('navigate backUntil and back', (tester) async {
    await tester.pumpWidget(NavigationApp());
    expect(find.byType(Home), findsOneWidget);

    RM.navigate.toNamed('/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.toNamed('/PageTwo');
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.toNamed('/PageThree');
    await tester.pumpAndSettle();
    expect(find.byType(PageThree), findsOneWidget);

    RM.navigate.backUntil('/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('navigate backAndToNamed and back', (tester) async {
    await tester.pumpWidget(NavigationApp());
    expect(find.byType(Home), findsOneWidget);

    RM.navigate.toNamed('/PageOne');
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.toNamed('/PageTwo');
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);

    RM.navigate.backAndToNamed('/PageThree');
    await tester.pumpAndSettle();
    expect(find.byType(PageThree), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });
}

class NavigationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RM.navigate.navigatorKey,
      routes: {
        '/': (_) => Home(),
        '/PageOne': (_) => PageOne(),
        '/PageTwo': (_) => PageTwo(),
        '/PageThree': (_) => PageThree(),
      },
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('home');
    return Text('Home');
  }
}

class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('page1');
    return Text('Page one');
  }
}

class PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('page2');
    return Text('Page two');
  }
}

class PageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('page3');
    return Text('Page three');
  }
}

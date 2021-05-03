import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  bool isTop = false;
  bool isBottom = false;
  bool isScrolling = false;
  bool isScrollingUp = false;
  bool isScrollingDown = false;
  bool hasStarted = false;
  bool hasStartedUp = false;
  bool hasStartedDown = false;
  bool hasEnded = false;
  final scroll = RM.injectScrolling(
    onScroll: (scroll) {
      isTop = scroll.hasReachedTheTop;
      isBottom = scroll.hasReachedTheBottom;
      //
      isScrolling = scroll.isScrolling;
      isScrollingUp = scroll.isScrollingReverse;
      isScrollingDown = scroll.isScrollingForward;
      //
      hasStarted = scroll.hasStartedScrolling;
      hasStartedUp = scroll.hasStartedScrollingReverse;
      hasStartedDown = scroll.hasStartedScrollingForward;
      //
      hasEnded = scroll.hasEndedScrolling;
    },
  );

  setUp(() {
    isTop = false;
    isBottom = false;
    isScrolling = false;
    isScrollingUp = false;
    isScrollingDown = false;
    hasStarted = false;
    hasStartedUp = false;
    hasStartedDown = false;
    hasEnded = false;
  });
  testWidgets(
    'WHEN InjectedScrolling is associated with a listView'
    'THEN the state is a fraction of current offset to the maxScrollExtent',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: On.scroll(
              (scroll) {
                return Text('offset: ${scroll.offset}');
              },
            ).listenTo(scroll),
          ),
          body: ListView.builder(
            controller: scroll.controller,
            itemCount: 20,
            itemBuilder: (_, i) {
              return ListTile(
                title: Text('Item $i'),
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      final maxScrollExtent = scroll.controller.position.maxScrollExtent;
      expect(scroll.offset, 0.0);
      expect(find.text('offset: 0.0'), findsOneWidget);
      //
      scroll.moveTo(10);
      await tester.pump(Duration.zero);
      expect(scroll.offset, 10.0);
      expect(scroll.offset, maxScrollExtent * scroll.state);
      expect(find.text('offset: 10.0'), findsOneWidget);

      //
      scroll.state = 0.5;
      await tester.pump(Duration.zero);
      expect(scroll.offset, maxScrollExtent / 2);
      expect(find.text('offset: ${scroll.offset}'), findsOneWidget);

      scroll.state = 1.0;
      await tester.pump(Duration.zero);
      expect(scroll.offset, maxScrollExtent);
      expect(find.text('offset: ${scroll.offset}'), findsOneWidget);
      //
      scroll.moveTo(
        0.0,
        duration: Duration(seconds: 1),
        curve: Curves.linear,
        clamp: false,
      );
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      expect(scroll.offset, maxScrollExtent / 2);
      expect(find.text('offset: ${scroll.offset}'), findsOneWidget);
      //
      await tester.pump(Duration(milliseconds: 500));
      await tester.pump(Duration(milliseconds: 300));
      expect(scroll.offset, 0.0);
      expect(find.text('offset: 0.0'), findsOneWidget);
    },
  );

  testWidgets(
    'Test scrolling flags forward direction'
    'THEN',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        upperBound: 600,
      );
      final widget = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: On.animation((animate) => Container()).listenTo(animation),
            title: On.scroll(
              (scroll) {
                if (scroll.hasReachedTheTop) {
                  return Text('isTop');
                }

                if (scroll.hasReachedTheBottom) {
                  return Text('isBottom');
                }

                if (scroll.hasStartedScrollingReverse) {
                  return Text('hasStartedUp');
                }
                if (scroll.hasStartedScrollingForward) {
                  return Text('hasStartedDown');
                }

                if (scroll.hasStartedScrolling) {
                  return Text('hasStarted');
                }

                if (scroll.isScrollingReverse) {
                  return Text('isScrollingUp');
                }
                if (scroll.isScrollingForward) {
                  return Text('isScrollingDown');
                }

                if (scroll.isScrolling) {
                  return Text('isScrolling');
                }

                if (scroll.hasEndedScrolling) {
                  return Text('hasEnded');
                }
                return Text('NAN');
              },
            ).listenTo(scroll),
          ),
          body: ListView.builder(
            controller: scroll.controller,
            itemCount: 20,
            itemBuilder: (_, i) {
              return ListTile(
                title: Text('Item $i'),
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, false);
      expect(isScrollingUp, false);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsOneWidget); // isTop == true,
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('isScrolling'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasEnded'), findsNothing);
      //
      animation.subscribeToRM((snap) async {
        await tester.drag(find.byType(ListView), Offset(0, -1));
      });
      animation.controller!.forward();
      //
      await tester.pump();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, true);
      expect(isScrollingUp, true);
      expect(isScrollingDown, false);
      expect(hasStarted, true);
      expect(hasStartedUp, true);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsOneWidget);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsNothing);
      expect(find.text('hasEnded'), findsNothing);
      //
      await tester.pump();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, true);
      expect(isScrollingUp, true);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsOneWidget);
      expect(find.text('hasEnded'), findsNothing);
      //
      await tester.pump();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, true);
      expect(isScrollingUp, true);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsOneWidget);
      expect(find.text('hasEnded'), findsNothing);
      //
      await tester.pumpAndSettle();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, true);
      expect(isScrollingUp, true);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsOneWidget);
      expect(find.text('hasEnded'), findsNothing);
      //
      await tester.pump(Duration(milliseconds: 300));
      await tester.pump();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, false);
      expect(isScrollingUp, false);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, true);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsNothing);
      expect(find.text('hasEnded'), findsOneWidget);
    },
  );

  testWidgets(
    'Test scrolling flags forward and revers direction'
    'THEN',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        upperBound: 600,
      );
      final widget = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: On.animation((animate) => Container()).listenTo(animation),
            title: On.scroll(
              (scroll) {
                if (scroll.hasReachedTheTop) {
                  return Text('isTop');
                }

                if (scroll.hasReachedTheBottom) {
                  return Text('isBottom');
                }

                if (scroll.hasStartedScrollingReverse) {
                  return Text('hasStartedUp');
                }
                if (scroll.hasStartedScrollingForward) {
                  return Text('hasStartedDown');
                }

                if (scroll.hasStartedScrolling) {
                  return Text('hasStarted');
                }

                if (scroll.isScrollingReverse) {
                  return Text('isScrollingUp');
                }
                if (scroll.isScrollingForward) {
                  return Text('isScrollingDown');
                }

                if (scroll.isScrolling) {
                  return Text('isScrolling');
                }

                if (scroll.hasEndedScrolling) {
                  return Text('hasEnded');
                }
                return Text('NAN');
              },
            ).listenTo(scroll),
          ),
          body: ListView.builder(
            controller: scroll.controller,
            itemCount: 20,
            itemBuilder: (_, i) {
              return ListTile(
                title: Text('Item $i'),
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, false);
      expect(isScrollingUp, false);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsOneWidget); // isTop == true,
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('isScrolling'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasEnded'), findsNothing);
      //
      animation.subscribeToRM((snap) async {
        await tester.drag(find.byType(ListView),
            Offset(0, -(animation.controller!.value + 1)));
      });
      animation.controller!.forward();
      //
      await tester.pump();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, true);
      expect(isScrollingUp, true);
      expect(isScrollingDown, false);
      expect(hasStarted, true);
      expect(hasStartedUp, true);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsOneWidget);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsNothing);
      expect(find.text('hasEnded'), findsNothing);
      //
      await tester.pump();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, true);
      expect(isScrollingUp, true);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsOneWidget);
      expect(find.text('hasEnded'), findsNothing);
      //
      await tester.pump();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, true);
      expect(isScrollingUp, true);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsOneWidget);
      expect(find.text('hasEnded'), findsNothing);
      //
      await tester.pumpAndSettle();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, false);
      expect(isScrollingUp, false);
      expect(isScrollingDown, false);
      expect(hasStarted, false);
      expect(hasStartedUp, false);
      expect(hasStartedDown, false);
      expect(hasEnded, true);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsNothing);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsNothing);
      expect(find.text('hasEnded'), findsOneWidget);
      //
      await tester.pump(Duration(milliseconds: 300));
      await tester.drag(find.byType(ListView), Offset(0, 10));
      await tester.pump();
      expect(isTop, false);
      expect(isBottom, false);
      expect(isScrolling, true);
      expect(isScrollingUp, false);
      expect(isScrollingDown, true);
      expect(hasStarted, true);
      expect(hasStartedUp, false);
      expect(hasStartedDown, true);
      expect(hasEnded, false);
      expect(find.text('isTop'), findsNothing);
      expect(find.text('isBottom'), findsNothing);
      expect(find.text('hasStartedUp'), findsNothing);
      expect(find.text('hasStartedDown'), findsOneWidget);
      expect(find.text('hasStarted'), findsNothing);
      expect(find.text('isScrollingUp'), findsNothing);
      expect(find.text('isScrollingDown'), findsNothing);
      expect(find.text('isScrolling'), findsNothing);
      expect(find.text('hasEnded'), findsNothing);
      await tester.pump(Duration(milliseconds: 300));
    },
  );
}

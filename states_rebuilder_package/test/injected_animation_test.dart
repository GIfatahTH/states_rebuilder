import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'WHEN two double , AlignmentGeometry, tow EdgeInsetsGeometry, constraints, color and  decoration are fined'
    'THEN they are implicitly animated',
    (tester) async {
      bool selected = false;
      double? height;
      double? width;
      AlignmentGeometry? alignment;
      EdgeInsetsGeometry? padding;
      EdgeInsetsGeometry? margin;
      BoxConstraints? constraints;
      Color? color;
      Decoration? decoration;
      final model = RM.inject(() => 0);
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );

      await tester.pumpWidget(
        On(
          () => On.animation(
            (animate) {
              return Container(
                height: height = animate(selected ? 100 : 0),
                width: width = animate(selected ? 50 : 0, 'width'),
                padding: padding = animate(
                    selected ? EdgeInsets.all(100) : EdgeInsets.all(10))!,
                margin: margin = animate(
                    selected ? EdgeInsets.all(100) : EdgeInsets.all(10),
                    'margin')!,
                alignment: alignment = animate(
                    selected ? Alignment.topLeft : Alignment.bottomRight)!,
                constraints: constraints = animate(selected
                    ? BoxConstraints(maxHeight: 0, maxWidth: 0)
                    : BoxConstraints(maxHeight: 100, maxWidth: 100)),
                color: color = animate(selected ? Colors.white : Colors.red),
                foregroundDecoration: decoration = animate(selected
                    ? BoxDecoration(color: Colors.white)
                    : BoxDecoration(color: Colors.red)),
                child: Container(),
              );
            },
          ).listenTo(animation),
        ).listenTo(model),
      );
      expect('$height', '0.0');
      expect('$width', '0.0');
      expect('$alignment', 'Alignment.bottomRight');
      expect('$padding', 'EdgeInsets.all(10.0)');
      expect('$margin', 'EdgeInsets.all(10.0)');
      expect('$constraints', 'BoxConstraints(0.0<=w<=100.0, 0.0<=h<=100.0)');
      expect('$color', 'MaterialColor(primary value: Color(0xfff44336))');
      expect('$decoration',
          'BoxDecoration(color: MaterialColor(primary value: Color(0xfff44336)))');

      selected = !selected;
      model.notify();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      expect('$height', '50.0');
      expect('$width', '25.0');
      expect('$alignment', 'Alignment.center');
      expect('$padding', 'EdgeInsets.all(55.0)');
      expect('$margin', 'EdgeInsets.all(55.0)');
      expect('$constraints', 'BoxConstraints(0.0<=w<=50.0, 0.0<=h<=50.0)');
      expect('$color', 'Color(0xfff9a19a)');
      expect('$decoration', 'BoxDecoration(color: Color(0xfff9a19a))');

      await tester.pumpAndSettle(Duration(milliseconds: 500));
      expect('$height', '100.0');
      expect('$width', '50.0');
      expect('$alignment', 'Alignment.topLeft');
      expect('$padding', 'EdgeInsets.all(100.0)');
      expect('$margin', 'EdgeInsets.all(100.0)');
      expect('$constraints', 'BoxConstraints(w=0.0, h=0.0)');
      expect('$color', 'Color(0xffffffff)');
      expect('$decoration', 'BoxDecoration(color: Color(0xffffffff))');
    },
  );

  testWidgets(
    'WHEN  AlignmentGeometry, tow EdgeInsetsGeometry, constraints, color and  decoration are fined'
    'With some null value'
    'THEN the app works',
    (tester) async {
      bool selected = false;

      AlignmentGeometry? alignment;
      EdgeInsetsGeometry? padding;
      EdgeInsetsGeometry? margin;
      BoxConstraints? constraints;
      Color? color;
      Decoration? decoration;
      final model = RM.inject(() => 0);
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );

      await tester.pumpWidget(On(
        () => On.animation(
          (animate) {
            return Container(
              padding: padding = animate(selected ? EdgeInsets.all(100) : null),
              margin: margin =
                  animate(selected ? null : EdgeInsets.all(10), 'margin'),
              alignment: alignment =
                  animate(selected ? Alignment.topLeft : null),
              constraints: constraints = animate(selected
                  ? null
                  : BoxConstraints(maxHeight: 100, maxWidth: 100)),
              color: color = animate(selected ? null : Colors.red),
              foregroundDecoration: decoration =
                  animate(selected ? BoxDecoration(color: Colors.white) : null),
              child: Container(),
            );
          },
        ).listenTo(animation),
      ).listenTo(model));

      expect('$alignment', 'null');
      expect('$padding', 'null');
      expect('$margin', 'EdgeInsets.all(10.0)');
      expect('$constraints', 'BoxConstraints(0.0<=w<=100.0, 0.0<=h<=100.0)');
      expect('$color', 'MaterialColor(primary value: Color(0xfff44336))');
      expect('$decoration', 'null');

      selected = !selected;
      model.notify();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));

      expect('$alignment', 'Alignment(-0.5, -0.5)');
      expect('$padding', 'EdgeInsets.all(50.0)');
      expect('$margin', 'EdgeInsets.all(5.0)');
      expect('$constraints', 'BoxConstraints(0.0<=w<=50.0, 0.0<=h<=50.0)');
      expect('$color', 'Color(0x80f44336)');
      expect('$decoration', 'BoxDecoration(color: Color(0x80ffffff))');

      await tester.pumpAndSettle(Duration(milliseconds: 500));

      expect('$alignment', 'Alignment.topLeft');
      expect('$padding', 'EdgeInsets.all(100.0)');
      expect('$margin', 'null');
      expect('$constraints', 'null');
      expect('$color', 'null');
      expect('$decoration', 'BoxDecoration(color: Color(0xffffffff))');
    },
  );
  testWidgets(
    'WHEN two variable of the same type and same name are used'
    'THEN it will throw an ArgumentError',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );
      await tester.pumpWidget(On.animation(
        (animate) {
          return Container(
            width: animate(100)!,
            height: animate(50)!,
          );
        },
      ).listenTo(animation));

      expect(tester.takeException(), isArgumentError);
    },
  );
  final animation = RM.injectAnimation(duration: Duration(seconds: 1));

  testWidgets(
    'WHEN rebuild is performed during animation and implicit parameters are changed'
    'THEN the animation works as expected similar to flutter implicit animation'
    'CASE one On.animation listener',
    (tester) async {
      final isSelected = false.inj();
      late Container container1;
      final widget = On(() {
        return Column(
          children: [
            On.animation(
              (animate) => container1 = Container(
                width: animate(isSelected.state ? 100 : 200),
              ),
            ).listenTo(animation),
          ],
        );
      }).listenTo(isSelected);
      await tester.pumpWidget(widget);
      expect(container1.constraints!.maxWidth, 200.0);
      isSelected.toggle();
      await tester.pump();
      expect(container1.constraints!.maxWidth, 200.0);
      await tester.pump(Duration(milliseconds: 400));

      expect(container1.constraints!.maxWidth, 160.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(container1.constraints!.maxWidth, 120.0);
      isSelected.toggle();
      await tester.pump();
      expect(container1.constraints!.maxWidth, 120.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(container1.constraints!.maxWidth, 152.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(container1.constraints!.maxWidth, 184.0);
      await tester.pump(Duration(milliseconds: 200));
      expect(container1.constraints!.maxWidth, 200.0);
    },
  );

  testWidgets(
    'WHEN rebuild is performed during animation and implicit parameters are changed'
    'THEN the animation works as expected similar to flutter implicit animation'
    'CASE many On.animation listeners',
    (tester) async {
      final isSelected = false.inj();
      late Container container1;
      late Container container2;

      final widget = On(() {
        return Column(
          children: [
            On.animation(
              (animate) => container1 = Container(
                width: animate(isSelected.state ? 100 : 200),
              ),
            ).listenTo(animation),
            On.animation(
              (animate) => container2 = Container(
                width: animate(isSelected.state ? 100 : 200),
              ),
            ).listenTo(animation),
          ],
        );
      }).listenTo(isSelected);
      await tester.pumpWidget(widget);
      expect(container1.constraints!.maxWidth, 200.0);
      expect(container2.constraints!.maxWidth, 200.0);
      isSelected.toggle();
      await tester.pump();
      expect(container1.constraints!.maxWidth, 200.0);
      expect(container2.constraints!.maxWidth, 200.0);
      await tester.pump();

      await tester.pump(Duration(milliseconds: 400));

      expect(container1.constraints!.maxWidth, 160.0);
      expect(container2.constraints!.maxWidth, 160.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(container1.constraints!.maxWidth, 120.0);
      expect(container2.constraints!.maxWidth, 120.0);
      isSelected.toggle();
      await tester.pump();
      await tester.pump();
      expect(container1.constraints!.maxWidth, 120.0);
      expect(container2.constraints!.maxWidth, 120.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(container1.constraints!.maxWidth, 152.0);
      expect(container2.constraints!.maxWidth, 152.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(container1.constraints!.maxWidth, 184.0);
      expect(container2.constraints!.maxWidth, 184.0);
      await tester.pump(Duration(milliseconds: 200));
      expect(container1.constraints!.maxWidth, 200.0);
      expect(container2.constraints!.maxWidth, 200.0);
    },
  );

  testWidgets(
    'WHEN SlideTransition (or any ...Transition widgets) is used, and the animate param is not used'
    'THEN the curved animation is obtained and On.animation does not rebuild',
    (tester) async {
      int numberOfOnAnimationRebuild = 0;
      late Animation<Offset> anim;
      final widget = On.animation(
        (_) {
          numberOfOnAnimationRebuild++;
          return SlideTransition(
            position: anim = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(1, 1),
            ).animate(
              animation.curvedAnimation,
            ),
            child: Container(),
          );
        },
      ).listenTo(
        animation,
        onInitialized: () => animation.triggerAnimation(),
      );

      await tester.pumpWidget(widget);
      expect(numberOfOnAnimationRebuild, 1);
      expect(anim.value, Offset(0.0, 0.0));
      await tester.pump(Duration(milliseconds: 400));
      expect(numberOfOnAnimationRebuild, 1);
      expect(anim.value, Offset(0.4, 0.4));
      await tester.pump(Duration(milliseconds: 400));
      expect(numberOfOnAnimationRebuild, 1);
      expect(anim.value, Offset(0.8, 0.8));
      await tester.pump(Duration(milliseconds: 400));
      expect(numberOfOnAnimationRebuild, 1);
      expect(anim.value, Offset(1.0, 1.0));
    },
  );

  testWidgets(
    'WHEN repeats is 2'
    'THEN animation repeats two times and stop',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        repeats: 2,
      );
      late double width;
      final widget = On.animation(
        (animate) => Container(
          width: width = animate.formTween(
            (_) => Tween(begin: 0.0, end: 100.0),
          )!,
        ),
      ).listenTo(animation);

      await tester.pumpWidget(widget);
      expect(width, 0.0);
      await tester.pump(Duration(milliseconds: 500));
      expect(width, 50.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(width, 90.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 100.0);
      await tester.pump(Duration(milliseconds: 100));

      expect(width, 0.0);
      await tester.pump(Duration(milliseconds: 500));
      expect(width, 50.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(width, 90.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 100.0);
    },
  );

  testWidgets(
    'WHEN repeats is 2 and  shouldReverseRepeats is true'
    'THEN animation cycle two times and stop',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        repeats: 2,
        shouldReverseRepeats: true,
      );
      late double width;
      final widget = On.animation(
        (animate) => Container(
          width: width = animate.formTween(
            (_) => Tween(begin: _ ?? 0.0, end: 100.0),
          )!,
        ),
      ).listenTo(animation);

      await tester.pumpWidget(widget);
      expect(width, 0.0);
      await tester.pump(Duration(milliseconds: 500));
      expect(width, 50.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(width, 90.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 100.0);
      await tester.pump(Duration(milliseconds: 100));

      expect(width, 100.0);
      await tester.pump(Duration(milliseconds: 500));
      expect(width, 50.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(width, 9.999999999999998);
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 0.0);
    },
  );
}

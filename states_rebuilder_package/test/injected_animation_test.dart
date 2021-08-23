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

      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );

      await tester.pumpWidget(
        animation.rebuild.onAnimation(
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
        ),
      );

      expect('$alignment', 'null');
      expect('$padding', 'null');
      expect('$margin', 'EdgeInsets.all(10.0)');
      expect('$constraints', 'BoxConstraints(0.0<=w<=100.0, 0.0<=h<=100.0)');
      expect('$color', 'MaterialColor(primary value: Color(0xfff44336))');
      expect('$decoration', 'null');

      selected = !selected;
      animation.refresh();
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
      int endAnimationNum = 0;
      final animation = RM.injectAnimation(
          duration: Duration(seconds: 1),
          repeats: 2,
          shouldAutoStart: true,
          endAnimationListener: () {
            endAnimationNum++;
          });
      late double width;
      final widget = On.animation(
        (animate) => Container(
          width: width = animate.fromTween(
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
      //
      expect(width, 0.0);
      await tester.pump(Duration(milliseconds: 500));
      expect(width, 50.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(width, 90.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 100.0);
      expect(endAnimationNum, 0);
      await tester.pumpAndSettle();
      expect(endAnimationNum, 1);
    },
  );

  testWidgets(
    'WHEN repeats is 2 and  shouldReverseRepeats is true'
    'THEN animation cycle two times and stop',
    (tester) async {
      int endAnimationNum = 0;
      final animation = RM.injectAnimation(
          duration: Duration(seconds: 1),
          repeats: 3,
          shouldReverseRepeats: true,
          endAnimationListener: () {
            endAnimationNum++;
          });
      late double width;
      final widget = animation.rebuild.onAnimation(
        (animate) => Container(
          width: width = animate.fromTween(
            (_) => Tween(begin: _ ?? 0.0, end: 100.0),
          )!,
        ),
        onInitialized: () {
          animation.triggerAnimation();
        },
      );

      // On.animation(
      //   (animate) => Container(
      //     width: width = animate.fromTween(
      //       (_) => Tween(begin: _ ?? 0.0, end: 100.0),
      //     )!,
      //   ),
      // ).listenTo(
      //   animation,
      //   onInitialized: () {
      //     animation.triggerAnimation();
      //   },
      // );

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
      expect(endAnimationNum, 0);
      await tester.pump(Duration(milliseconds: 100));

      expect(width, 0.0);
      await tester.pump(Duration(milliseconds: 500));
      expect(width, 50.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(width, 90.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 100.0);
      await tester.pumpAndSettle();
      expect(endAnimationNum, 1);
    },
  );

  testWidgets(
    'WHEN repeats is 2, and animation starts form upper bound.'
    'THEN animation repeats two times and stop',
    (tester) async {
      int endAnimationNum = 0;
      final animation = RM.injectAnimation(
          initialValue: 1,
          duration: Duration(seconds: 1),
          repeats: 2,
          shouldAutoStart: true,
          endAnimationListener: () {
            endAnimationNum++;
          });
      late double width;
      final widget = On.animation(
        (animate) => Container(
          width: width = animate.fromTween(
            (_) => Tween(begin: 0.0, end: 100.0),
          )!,
        ),
      ).listenTo(animation);

      await tester.pumpWidget(widget);

      expect(width, 100.0);
      await tester.pump(Duration(milliseconds: 500));
      expect(width, 50.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(width, 9.999999999999998);
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 0.0);
      await tester.pump(Duration(milliseconds: 100));
      //
      expect(width, 100.0);
      await tester.pump(Duration(milliseconds: 500));
      expect(width, 50.0);
      await tester.pump(Duration(milliseconds: 400));
      expect(width, 9.999999999999998);
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 0.0);
      expect(endAnimationNum, 0);
      await tester.pump(Duration(milliseconds: 100));
      expect(endAnimationNum, 1);
    },
  );

  testWidgets(
    'WHEN setCurve is defined for a particular value'
    'THEN it override the default Curve'
    'Case animate.call',
    (tester) async {
      bool isSelected = true;
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );
      late double value0;
      late double value1;
      late double value2;
      final widget = On.animation(
        (animate) {
          value0 = animate(isSelected ? 0 : 100)!;
          value1 = animate.setCurve(Interval(0, 0.5)).call(
                isSelected ? 0 : 100,
                'value1',
              )!;
          value2 = animate.setCurve(Interval(0.5, 1)).call(
                isSelected ? 0 : 100,
                'value2',
              )!;
          return Container();
        },
      ).listenTo(animation);
      await tester.pumpWidget(widget);
      expect(value0, 0.0);
      expect(value1, 0.0);
      expect(value2, 0.0);
      isSelected = !isSelected;
      animation.refresh();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      expect(value0, 10.0);
      expect(value1, 20.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 200));
      expect(value0, 30.0);
      expect(value1, 60.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 200));
      expect(value0, 50.0);
      expect(value1, 100.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(value0, 60.0);
      expect(value1, 100.0);
      expect(value2, 19.999999999999996);
      await tester.pump(Duration(milliseconds: 200));
      expect(value0, 80.0);
      expect(value1, 100.0);
      expect(value2, 60.00000000000001);
      await tester.pump(Duration(milliseconds: 200));
      expect(value0, 100.0);
      expect(value1, 100.0);
      expect(value2, 100.0);
    },
  );

  testWidgets(
    'WHEN setReversCurve is defined for a particular value'
    'THEN it override the default Curve'
    'Case animate.call',
    (tester) async {
      bool isSelected = true;
      final animation = RM.injectAnimation(
        initialValue: 1,
        duration: Duration(seconds: 1),
        curve: Curves.bounceInOut,
        reverseCurve: Curves.linear,
      );
      late double value0;
      late double value1;
      late double value2;
      final widget = On.animation(
        (animate) {
          value0 = animate(isSelected ? 0 : 100)!;
          value1 = animate.setReverseCurve(Interval(0, 0.5)).call(
                isSelected ? 0 : 100,
                'value1',
              )!;
          value2 = animate.setReverseCurve(Interval(0.5, 1)).call(
                isSelected ? 0 : 100,
                'value2',
              )!;
          return Container();
        },
      ).listenTo(animation);
      await tester.pumpWidget(widget);
      expect(value0, 0.0);
      expect(value1, 0.0);
      expect(value2, 0.0);
      isSelected = !isSelected;
      animation.refresh();
      await tester.pump();
      await tester.pump(); //Better one frame
      expect(value0, 100.0);
      expect(value1, 100.0);
      expect(value2, 100.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(value0, 90.0);
      expect(value1, 100.0);
      expect(value2, 80.0);
      await tester.pump(Duration(milliseconds: 200));

      expect(value0, 70.0);
      expect(value1, 100.0);
      expect(value2, 39.99999999999999);
      await tester.pump(Duration(milliseconds: 200));

      expect(value0, 50.0);
      expect(value1, 100.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 100));

      expect(value0, 40.0);
      expect(value1, 80.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 200));

      expect(value0, 19.999999999999996);
      expect(value1, 39.99999999999999);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 200));

      expect(value0, 0.0);
      expect(value1, 0.0);
      expect(value2, 0.0);
    },
  );

  testWidgets(
    'WHEN setCurve is defined for a particular value'
    'THEN it override the default Curve'
    'Case animate.fromTween',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        shouldAutoStart: true,
      );
      late double value0;
      late double value1;
      late double value2;
      final widget = On.animation(
        (animate) {
          value0 = animate.fromTween((_) => Tween(begin: 0, end: 100))!;
          value1 = animate.setCurve(Interval(0, 0.5)).fromTween(
                (_) => Tween(begin: 0, end: 100),
                'value1',
              )!;
          value2 = animate.setCurve(Interval(0.5, 1)).fromTween(
                (_) => Tween(begin: 0, end: 100),
                'value2',
              )!;
          return Container();
        },
      ).listenTo(animation);
      await tester.pumpWidget(widget);
      expect(value0, 0.0);
      expect(value1, 0.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(value0, 10.0);
      expect(value1, 20.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 200));
      expect(value0, 30.0);
      expect(value1, 60.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 200));
      expect(value0, 50.0);
      expect(value1, 100.0);
      expect(value2, 0.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(value0, 60.0);
      expect(value1, 100.0);
      expect(value2, 19.999999999999996);
      await tester.pump(Duration(milliseconds: 200));
      expect(value0, 80.0);
      expect(value1, 100.0);
      expect(value2, 60.00000000000001);
      await tester.pump(Duration(milliseconds: 200));
      expect(value0, 100.0);
      expect(value1, 100.0);
      expect(value2, 100.0);
    },
  );

  testWidgets(
    'Animation can be used with per built flutter transition widget'
    'Animation is triggered using triggerAnimation method',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        shouldAutoStart: true,
      );
      await tester.pumpWidget(
        On.animation(
          (_) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: SizeTransition(
                sizeFactor: animation.curvedAnimation,
                child: Container(
                  width: 100,
                ),
              ),
            );
          },
        ).listenTo(
          animation,
          // onInitialized: () {
          //   animation.triggerAnimation();
          // },
        ),
      );
      expect(animation.curvedAnimation.value, 0.0);
      await tester.pump(Duration(milliseconds: 100));
      expect(animation.curvedAnimation.value, 0.1);
      await tester.pumpAndSettle();
      expect(animation.curvedAnimation.value, 1.0);
    },
  );

  testWidgets(
    'test various tweens'
    'THEN',
    (tester) async {
      bool isSelected = true;

      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );

      late Offset offset;
      late Size size;
      late TextStyle textStyle;
      late Rect rect;
      late RelativeRect relativeRect;
      late int _int;
      late BorderRadius borderRadius;
      late ThemeData themeData;
      late Matrix4 matrix4;

      await tester.pumpWidget(Column(
        children: [
          On.animation(
            (animate) {
              return Transform.translate(
                offset: offset = animate(
                  isSelected ? Offset.zero : Offset(10, 10),
                )!,
                child: Container(),
              );
            },
          ).listenTo(animation),
          On.animation(
            (animate) {
              return SizedBox.fromSize(
                size: size = animate(
                  isSelected ? Size.zero : Size(10, 10),
                )!,
              );
            },
          ).listenTo(animation),
          On.animation(
            (animate) {
              textStyle = animate(
                isSelected
                    ? TextStyle(color: Colors.red)
                    : TextStyle(color: Colors.blue),
              )!;
              rect = animate(
                isSelected ? Rect.zero : Rect.fromLTRB(10, 10, 10, 10),
              )!;
              relativeRect = animate(
                isSelected
                    ? RelativeRect.fromLTRB(0, 0, 0, 0)
                    : RelativeRect.fromLTRB(10, 10, 10, 10),
              )!;

              _int = animate(
                isSelected ? 0 : 10,
              )!;

              borderRadius = animate(
                isSelected ? BorderRadius.zero : BorderRadius.circular(10),
              )!;

              themeData = animate(
                isSelected ? ThemeData.dark() : ThemeData.light(),
              )!;

              matrix4 = animate(
                isSelected
                    ? Matrix4.zero()
                    : Matrix4.diagonal3Values(10, 10, 10),
              )!;

              return Container();
            },
          ).listenTo(animation),
        ],
      ));

      expect(offset, Offset.zero);
      expect(size, Size.zero);
      expect(textStyle.color, Colors.red);
      expect(rect, Rect.zero);
      expect(relativeRect, RelativeRect.fromLTRB(0, 0, 0, 0));
      expect(_int, 0);
      expect(borderRadius, BorderRadius.zero);
      expect(themeData.colorScheme.brightness, Brightness.dark);
      expect(matrix4, Matrix4.zero());

      //
      isSelected = false;
      animation.refresh();
      await tester.pumpAndSettle();
      expect(offset, Offset(10, 10));
      expect(size, Size(10, 10));
      expect(textStyle.color, Colors.blue);
      expect(rect, Rect.fromLTRB(10, 10, 10, 10));
      expect(relativeRect, RelativeRect.fromLTRB(10, 10, 10, 10));
      expect(_int, 10);
      expect(borderRadius, BorderRadius.circular(10));
      expect(themeData.colorScheme.brightness, Brightness.light);
      expect(matrix4, Matrix4.diagonal3Values(10, 10, 10));
    },
  );

  testWidgets(
    'test various tweens extension',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        shouldAutoStart: true,
      );
      late double _double;
      late Color color;
      late AlignmentGeometry alignmentGeometry;
      late EdgeInsetsGeometry edgeInsetsGeometry;
      late Decoration decoration;
      late BoxConstraints boxConstraints;
      late Offset offset;
      late Size size;
      late TextStyle textStyle;
      late Rect rect;
      late RelativeRect relativeRect;
      late int _int;
      late BorderRadius borderRadius;
      late ThemeData themeData;
      late Matrix4 matrix4;

      await tester.pumpWidget(Column(
        children: [
          On.animation(
            (animate) {
              return Transform.translate(
                offset: offset = animate.fromTween(
                  (currentValue) => Offset.zero.tweenTo(Offset(10, 10)),
                )!,
                child: Container(),
              );
            },
          ).listenTo(animation),
          On.animation(
            (animate) {
              return SizedBox.fromSize(
                size: size = animate.fromTween(
                  (currentValue) => Size.zero.tweenTo(Size(10, 10)),
                )!,
              );
            },
          ).listenTo(animation),
          On.animation(
            (animate) {
              _double = animate.fromTween(
                (_) => 0.0.tweenTo(10.0),
              )!;
              color = animate.fromTween(
                (_) => Colors.red.tweenTo(Colors.blue),
              )!;
              alignmentGeometry = animate.fromTween(
                (_) => Alignment.topLeft.tweenTo(Alignment.topRight),
              )!;
              edgeInsetsGeometry = animate.fromTween(
                (_) => EdgeInsets.all(0).tweenTo(EdgeInsets.all(10)),
              )!;
              decoration = animate.fromTween(
                (_) => BoxDecoration(color: Colors.red)
                    .tweenTo(BoxDecoration(color: Colors.blue)),
              )!;
              boxConstraints = animate.fromTween(
                (_) => BoxConstraints(minWidth: 0)
                    .tweenTo(BoxConstraints(minWidth: 10)),
              )!;

              textStyle = animate.fromTween((currentValue) =>
                  TextStyle(color: Colors.red)
                      .tweenTo(TextStyle(color: Colors.blue)))!;

              rect = animate.fromTween(
                (_) => Rect.zero.tweenTo(Rect.fromLTRB(10, 10, 10, 10)),
              )!;

              relativeRect = animate.fromTween(
                (_) => RelativeRect.fromLTRB(0, 0, 0, 0)
                    .tweenTo(RelativeRect.fromLTRB(10, 10, 10, 10)),
              )!;

              _int = animate.fromTween(
                (_) => 0.tweenTo(10),
              )!;

              borderRadius = animate.fromTween(
                (_) => BorderRadius.zero.tweenTo(BorderRadius.circular(10)),
              )!;

              themeData = animate.fromTween(
                (_) => ThemeData.dark().tweenTo(ThemeData.light()),
              )!;

              matrix4 = animate.fromTween(
                (_) =>
                    Matrix4.zero().tweenTo(Matrix4.diagonal3Values(10, 10, 10)),
              )!;

              return Container();
            },
          ).listenTo(animation),
        ],
      ));
      expect(_double, 0.0);
      expect(color, Colors.red);
      expect(alignmentGeometry, Alignment.topLeft);
      expect(edgeInsetsGeometry, EdgeInsets.zero);
      expect(decoration, BoxDecoration(color: Colors.red));
      expect(boxConstraints.toString(), 'BoxConstraints(unconstrained)');
      expect(offset, Offset.zero);
      expect(size, Size.zero);
      expect(textStyle.color, Colors.red);
      expect(rect, Rect.zero);
      expect(relativeRect, RelativeRect.fromLTRB(0, 0, 0, 0));
      expect(_int, 0);
      expect(borderRadius, BorderRadius.zero);
      expect(themeData.colorScheme.brightness, Brightness.dark);
      expect(matrix4, Matrix4.zero());

      //
      await tester.pumpAndSettle();
      expect(_double, 10);
      expect(color, Colors.blue);
      expect(alignmentGeometry, Alignment.topRight);
      expect(edgeInsetsGeometry, EdgeInsets.all(10.0));
      expect(decoration, BoxDecoration(color: Colors.blue));
      expect(boxConstraints.toString(),
          'BoxConstraints(10.0<=w<=Infinity, 0.0<=h<=Infinity)');
      expect(offset, Offset(10, 10));
      expect(size, Size(10, 10));
      expect(textStyle.color, Colors.blue);
      expect(rect, Rect.fromLTRB(10, 10, 10, 10));
      expect(relativeRect, RelativeRect.fromLTRB(10, 10, 10, 10));
      expect(_int, 10);
      expect(borderRadius, BorderRadius.circular(10));
      expect(themeData.colorScheme.brightness, Brightness.light);
      expect(matrix4, Matrix4.diagonal3Values(10, 10, 10));
    },
  );
  testWidgets(
    'Test tween can not ne inferred'
    'THEN',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );

      await tester.pumpWidget(
        On.animation(
          (animate) {
            animate(Text(''));
            return Container();
          },
        ).listenTo(animation),
      );

      expect(tester.takeException(), isUnimplementedError);
    },
  );
  testWidgets(
    'throw an ArgumentError if two animate of the same type and name'
    'Case animate is defined inside a Builder',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: On.animation(
            (animate) {
              animate(1.0);
              return ListView.builder(
                  itemCount: 1,
                  itemBuilder: (_, __) {
                    animate(1.0);
                    return Container();
                  });
            },
          ).listenTo(animation),
        ),
      );

      expect(tester.takeException(), isArgumentError);
    },
  );

  testWidgets(
    'Do not throw an argument error'
    'When the animation is refreshed and in case one animate is build',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );
      final model = ''.inj();
      await tester.pumpWidget(
        MaterialApp(
          home: On.animation(
            (animate) {
              animate(1.0);
              return On(() {
                return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (_, __) {
                      animate(1.0, 'n');
                      return Container();
                    });
              }).listenTo(model);
            },
          ).listenTo(animation),
        ),
      );
      await tester.pumpAndSettle();
      //
      animation.refresh();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Nested animation inside ListView Builder works',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        repeats: 2,
        shouldReverseRepeats: true,
      );
      final model = ''.inj();
      double width = 0.0;
      double height = 0.0;
      bool selected = true;
      await tester.pumpWidget(
        MaterialApp(
          home: On.animation(
            (animate) {
              animate(1.0);
              return On(() {
                return ListView.builder(
                  itemCount: 1,
                  itemBuilder: (_, __) {
                    width = animate(selected ? 0.0 : 100.0, 'n')!;
                    return On.animation(
                      (animate) {
                        height = selected
                            ? animate.fromTween(
                                (_) => Tween(begin: 0, end: 100.0), 'n')!
                            : animate.fromTween(
                                (_) => Tween(begin: 0.0, end: 100.0), 'n')!;
                        return Container();
                      },
                    ).listenTo(animation);
                  },
                );
              }).listenTo(model);
            },
          ).listenTo(animation),
        ),
      );
      model.notify();
      await tester.pumpAndSettle();
      //
      selected = !selected;
      animation.refresh();
      await tester.pump();
      expect(width, 0);
      await tester.pump();
      expect(width, 0);
      expect(height, 0);
      model.notify();
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 10);
      expect(height, 10);

      model.notify();
      await tester.pump(Duration(milliseconds: 900));
      expect(width, 100);
      expect(height, 100);

      model.notify();
      await tester.pump(Duration(milliseconds: 100));
      await tester.pump(Duration(milliseconds: 100));
      expect(width, 90);
      expect(height, 90);
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      expect(width, 0);
      expect(height, 0);
      //100
    },
  );

  testWidgets(
    'Check curvedAnimation getter',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        reverseCurve: Curves.bounceIn,
        shouldReverseRepeats: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: On.animation(
            (animate) {
              animate.fromTween((_) => Tween(begin: 0.0, end: 1.0))!;
              return Container();
            },
          ).listenTo(animation),
        ),
      );
      expect(animation.curvedAnimation.toString(), endsWith('_Linear'));
      animation.triggerAnimation();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      expect(animation.curvedAnimation.toString(), endsWith('_Linear'));
      await tester.pumpAndSettle();
      animation.triggerAnimation();
      expect(animation.curvedAnimation.toString(), endsWith('_BounceInCurve'));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      expect(animation.curvedAnimation.toString(), endsWith('_BounceInCurve'));
      await tester.pumpAndSettle();
      expect(animation.curvedAnimation.toString(), endsWith('_BounceInCurve'));
    },
  );

  testWidgets(
    'reset Duration, reverseDuration and shouldReverseRepeats',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        shouldAutoStart: true,
      );
      late double value;
      await tester.pumpWidget(
        MaterialApp(
          home: On.animation(
            (animate) {
              value = animate.fromTween((_) => Tween(begin: 0.0, end: 100.0))!;
              return Container();
            },
          ).listenTo(animation),
        ),
      );
      expect(value, 0);
      await tester.pump(Duration(milliseconds: 200));
      expect(value, 20);
      await tester.pump(Duration(milliseconds: 300));
      expect(value, 50);
      await tester.pump(Duration(milliseconds: 200));
      expect(value, 70);
      await tester.pump(Duration(milliseconds: 300));
      expect(value, 100);
      animation.resetAnimation(duration: Duration(milliseconds: 100));
      animation.triggerAnimation(restart: true);
      await tester.pump();
      expect(value, 0.0);
      await tester.pump(Duration(milliseconds: 20));
      expect(value, 20);
      await tester.pump(Duration(milliseconds: 30));
      expect(value, 50);
      await tester.pump(Duration(milliseconds: 20));
      expect(value, 70);
      await tester.pump(Duration(milliseconds: 30));
      expect(value, 100);
      //
      animation.resetAnimation(duration: Duration(milliseconds: 1000));
      animation.triggerAnimation(restart: true);
      await tester.pump();
      await tester.pump(Duration(milliseconds: 200));
      expect(value, 20);
      await tester.pump(Duration(milliseconds: 300));
      animation.resetAnimation(duration: Duration(milliseconds: 100));
      expect(value, 50);
      await tester.pump(Duration(milliseconds: 200));
      expect(value, 70);
      await tester.pump(Duration(milliseconds: 300));
      expect(value, 100);
      animation.triggerAnimation(restart: true);
      await tester.pump();
      expect(value, 0.0);
      await tester.pump(Duration(milliseconds: 20));
      expect(value, 20);
      await tester.pump(Duration(milliseconds: 30));
      expect(value, 50);
      await tester.pump(Duration(milliseconds: 20));
      expect(value, 70);
      await tester.pump(Duration(milliseconds: 30));
      expect(value, 100);
      await tester.pumpAndSettle();
      //
      animation.resetAnimation(
        reverseDuration: Duration(milliseconds: 2000),
        shouldReverseRepeats: true,
      );
      animation.triggerAnimation();
      await tester.pump();
      expect(value, 100);
      await tester.pump(Duration(milliseconds: 400));
      expect(value, 80);
      await tester.pump(Duration(milliseconds: 600));
      expect(value, 50);
      await tester.pump(Duration(milliseconds: 400));
      expect(value, 30.000000000000004);
      await tester.pump(Duration(milliseconds: 600));
      expect(value, 0.0);

      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'reset repeats count',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
        shouldAutoStart: true,
        repeats: 3,
        shouldReverseRepeats: true,
      );
      late double value;
      late double valueOfController;
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              animation.rebuild.onAnimation(
                (animate) {
                  value =
                      animate.fromTween((_) => Tween(begin: 0.0, end: 100.0))!;
                  return Container();
                },
              ),
              animation.rebuild(() {
                valueOfController = animation.controller!.value;
                return Container();
              })
            ],
          ),
        ),
      );
      expect(value, 0);
      expect(valueOfController, 0);
      await tester.pumpAndSettle();
      expect(value, 100);
      expect(valueOfController, 1);
      animation.triggerAnimation();
      await tester.pumpAndSettle();
      expect(value, 0);
      //
      animation.resetAnimation(repeats: 2);
      animation.triggerAnimation();
      await tester.pumpAndSettle();
      expect(value, 0);
    },
  );

  testWidgets(
    'reset curve and reverse curve',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: Duration(seconds: 1),
      );
      late double value;
      late double value2;
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              On.animation(
                (animate) {
                  value =
                      animate.fromTween((_) => Tween(begin: 0.0, end: 100.0))!;
                  return Container();
                },
              ).listenTo(animation),
              On.animation(
                (animate) {
                  value2 =
                      animate.fromTween((_) => Tween(begin: 0.0, end: 100.0))!;
                  return Container();
                },
              ).listenTo(animation),
            ],
          ),
        ),
      );
      expect(value, 0);
      animation.controller!.forward();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      expect(animation.curvedAnimation.toString(), endsWith('_Linear'));
      expect(value, 50.0);
      expect(value2, 50.0);
      await tester.pumpAndSettle();
      expect(value, 100);
      expect(value2, 100);
      animation.resetAnimation(reverseCurve: Curves.bounceIn);
      animation.controller!.reverse();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      expect(animation.curvedAnimation.toString(), endsWith('_BounceInCurve'));
      expect(value, 23.4375);
      expect(value2, 23.4375);
      await tester.pumpAndSettle();
      expect(value, 0);
      expect(value2, 0);
      //
      animation.controller!.forward();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      expect(animation.curvedAnimation.toString(), endsWith('_Linear'));
      expect(value, 10);
      expect(value2, 10);
      animation.resetAnimation(curve: Curves.bounceIn);
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      expect(animation.curvedAnimation.toString(), endsWith('_BounceInCurve'));
      expect(value, 6.000000000000005);
      expect(value2, 6.000000000000005);
      await tester.pumpAndSettle();
      expect(value, 100);
      expect(value2, 100);
      expect(animation.curvedAnimation.toString(), endsWith('_BounceInCurve'));
    },
  );

  testWidgets(
    'WHEN'
    'THEN',
    (tester) async {
      final animation = RM.injectAnimation(duration: 1.seconds);
      double? value1;
      double? value2;
      double? value3;
      double? value4;
      final index = 1.inj();
      final widget = OnReactive(
        () => OnAnimationBuilder(
          listenTo: animation,
          builder: (animate) {
            value1 = animate(index.state == 1 ? 100 : 0, '1');
            value2 = animate(index.state == 2 ? 100 : 0, '2');
            value3 = animate(index.state == 3 ? 100 : 0, '3');
            value4 = animate(index.state == 4 ? 100 : 0, '4');
            return Container();
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(value1, 100);
      expect(value2, 0);
      expect(value3, 0);
      expect(value4, 0);
      //
      index.state = 2;
      await tester.pump();
      expect(value1, 100);
      expect(value2, 0);
      expect(value3, 0);
      expect(value4, 0);
      //
      await tester.pump(200.milliseconds);
      expect(value1, 80);
      expect(value2, 20);
      expect(value3, 0);
      expect(value4, 0);
      await tester.pump(600.milliseconds);
      expect(value1, 20);
      expect(value2, 80);
      expect(value3, 0);
      expect(value4, 0);
      await tester.pumpAndSettle();
      expect(value1, 0);
      expect(value2, 100);
      expect(value3, 0);
      expect(value4, 0);
      //
      index.state = 3;
      await tester.pump();
      // await tester.pump();
      expect(value1, 0);
      expect(value2, 100);
      expect(value3, 0);
      expect(value4, 0);
      //
      await tester.pump(200.milliseconds);
      expect(value1, 0);
      expect(value2, 80);
      expect(value3, 20);
      expect(value4, 0);
      await tester.pump(600.milliseconds);
      expect(value1, 0);
      expect(value2, 20);
      expect(value3, 80);
      expect(value4, 0);
      await tester.pumpAndSettle();
      expect(value1, 0);
      expect(value2, 0);
      expect(value3, 100);
      expect(value4, 0);
      //
      index.state = 4;
      await tester.pump();
      expect(value1, 0);
      expect(value2, 0);
      expect(value3, 100);
      expect(value4, 0);
      //
      await tester.pump(200.milliseconds);
      expect(value1, 0);
      expect(value2, 0);
      expect(value3, 80);
      expect(value4, 20);
      await tester.pump(600.milliseconds);
      expect(value1, 0);
      expect(value2, 0);
      expect(value3, 20);
      expect(value4, 80);
      await tester.pumpAndSettle();
      expect(value1, 0);
      expect(value2, 0);
      expect(value3, 0);
      expect(value4, 100);
      //
      index.state = 1;
      await tester.pump();
      expect(value1, 0);
      expect(value2, 0);
      expect(value3, 0);
      expect(value4, 100);
      //
      await tester.pump(200.milliseconds);
      expect(value1, 20);
      expect(value2, 0);
      expect(value3, 0);
      expect(value4, 80);
      await tester.pump(600.milliseconds);
      expect(value1, 80);
      expect(value2, 0);
      expect(value3, 0);
      expect(value4, 20);
      await tester.pumpAndSettle();
      expect(value1, 100);
      expect(value2, 0);
      expect(value3, 0);
      expect(value4, 0);
    },
  );

  testWidgets(
    'Test duration extensions',
    (tester) async {
      expect(10.milliseconds, Duration(milliseconds: 10));
      expect(10.seconds, Duration(seconds: 10));
      expect(10.minutes, Duration(minutes: 10));
      expect(10.hours, Duration(hours: 10));
    },
  );
}

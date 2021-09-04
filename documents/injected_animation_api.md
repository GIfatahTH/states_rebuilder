//OK
In Flutter, you can set animation either implicitly or explicitly. Implicit animation is the easiest and most recommended. But the implicit animation is limited by the fact that you have to find a built-in widget that starts with the Animated prefix; AnimatedFoo (ex: `AnimatedContainer`, `AnimatedAlign`, ..). On the other side, with explicit animation, you have full control over your animation settings but it's a bit verbose to set..

With states_rebuilder, you can set animation implicitly without any limitation or explicitly with practically no boilerplate. 

# Table of Contents <!-- omit in toc --> 
- [Injecting animation](#Injecting-animation)  
- [Implicit animation](#Implicit-animation)  
- [Explicit animation](#Explicit-animation)  
- [Use of Flutter's transition widgets](#Use-of-Flutter's-transition-widgets) - [InjectedAnimation methods](#InjectedAnimation-methods) 
  - [curvedAnimation](#curvedAnimation)  
  - [triggerAnimation](#triggerAnimation)  
   - [refresh](#refresh)  
- [staggered Animation](#staggered-Animation)  

## Injecting animation

First we need to inject the animation:

```dart
final animation = RM.injectAnimation(
  //Required parameter
  duration: const Duration(seconds: 2),
  //Optional parameters
  reverseDuration : null,
  curve: Curves.linear,
  reverseCurve: null, 
  initialValue: 0.0,
  lowerBound: 0.0,
  upperBound: 1.0,
  animationBehavior = AnimationBehavior.normal,
  repeats: 2,
  shouldReverseRepeats: true,
  shouldAutoStart: false,
  endAnimationListener: (){
    print('animation ends');
  }
);
```

- You have to define the duration of the animation.
- The default curve is `Curves.linear`.
- You can set another curve for the reverse animation using `reverseCurve`. If not defined or set to null, the `curve` parameter is used for both forward and backward animation.
- `curve` and `reverseCurve` defined here are the default ones. You can override them for any value using `Animate.setCurve` and `Animate.setReverse` curve methods (see staggered animation below).
- `initialValue` is the initial value you want the `AnimationController` to start with.
- `lowerBound`, `upperBound`, `animationBehavior` have similar meaning as in Flutter.
- If you want the animation to repeat a certain number of times, you define the “repeats” argument.
- If the animation is set to repeat, once the forward path is complete, it will go back to the beginning and start over.
- If `shouldReverseRepeats` is set to true, the animation will repeat the cycle from start to end and reverse from end to start and so on.
- `endAnimationListener` is used to performed side effects once animation is finished.
- If you use explicit animation, by default the animation does not start after first initialized. You can set `shouldAutoStart` to true if you want it to start automatically.
> Animation is auto disposed once no longer used. So do not worry about disposing of it.

## Implicit animation

Let's reproduce the `AnimatedContainer` example in official Flutter docs.  ([link here](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html)).

In Flutter `AnimatedContainer` example, we see:

```dart
Center(
    child: AnimatedContainer(
        width: selected ? 200.0 : 100.0,
        height: selected ? 100.0 : 200.0,
        color: selected ? Colors.red : Colors.blue,
        alignment: selected ? Alignment.center : AlignmentDirectional.topCenter,
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
        child: const FlutterLogo(size: 75),
    ),
),
```

With `states_rebuilder` animation, we simply use the `Container` widget :

```dart
Center(
    child: OnAnimationBuilder(
        listenTo: animation,
        builder: (animate) => Container(
            // Animate is a callable class
            width: animate.call(selected ? 200.0 : 100.0),
            height: animate(selected ? 100.0 : 200.0, 'height'),
            color: animate(selected ? Colors.red : Colors.blue),
            alignment: animate(selected ? Alignment.center : AlignmentDirectional.topCenter),
            child: const FlutterLogo(size: 75),
        ),
    ),
),
```
- `OnAnimationBuilder` is used to listen to the injected animation.
- `the builder method exposes the `animate` function.
- Using the exposed `animate` function, we set the animation start and end values.
- As the width and height are the same type (double), we need to add a name to distinguish them.

> You can implicitly animate any type. Here we implicitly animated a `double`, `Color`, and `Alignment` values. If you want to animate two parameters of the same type, you just add a dummy name to distinguish them.

That's all, you are not limited to use a widget that starts with Animated prefix to use implicit animation.

Note that you can use many `OnAnimationBuilder` for one injected animation.
ex:


```dart
Column(
    children: [
      OnAnimationBuilder(
        listenTo: animation,
        builder: (animate) => Container(
            width: animate.call(selected ? 200.0 : 100.0),
            height: animate(selected ? 100.0 : 200.0, 'height'),
            color: animate(selected ? Colors.red : Colors.blue),
            alignment: animate(selected ? Alignment.center : AlignmentDirectional.topCenter),
            child: const FlutterLogo(size: 75),
        ),
      ),
      OnAnimationBuilder(
        listenTo: animation,
        builder: (animate) => Transform.rotate(
            angle: animate(selected ? 0 : 2 * 3.14)!,
            child: const FlutterLogo(size: 75),
        ),
      ),
    ]
),
```
In the example above, we implicitly rotated the `FlutterLogo` (it has no prebuilt widget), and listened to the injected animation twice.

## Explicit animation

In explicit animation you have full control on how to parametrize your animation using tweens.

```dart
OnAnimationBuilder(
    listenTo: animation,
    builder: (animate) => Transform.rotate(
        angle: animate.fromTween(
            (currentValue) => Tween(begin: 0, end: 2 * 3.14),
        )!,
        child: const FlutterLogo(size: 75),
    ),
),
```

- The `FlutterLogo` will rotate from 0 to 2 * 3.14 (one turn)
- The `fromTween` exposes the current value of the angle. It may be used to animate from the current value to the next value. (See the example below)

> For rebuild performance use `Child`, `Child2` and `Child3` widget.

Example of a Clock:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final animation = RM.injectAnimation(
    duration: const Duration(seconds: 1),
    curve: Curves.easeInOut,
    onInitialized: (animation) {
      Timer.periodic(
        Duration(seconds: 1),
        (_) {
          //rebuild the OnAnimationBuilder listeners, and recalculate the new implicit 
          //animation values
          animation.refresh();
        },
      );
    });

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Clock')),
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(border: Border.all(width: 2.0)),
        child: Align(
          alignment: Alignment.topCenter,
          child: Child3(
            //Second rod
            child1: Container(
              width: 1,
              height: 100,
              color: Colors.red,
            ),
            //minute rod
            child2: Container(
              width: 2,
              height: 90,
              color: Colors.black,
            ),
            //hour rod
            child3: Container(
              width: 4,
              height: 80,
              color: Colors.black,
            ),
            builder: (secondRod, minuteRod, hourRod) => Stack(
              alignment: Alignment.bottomCenter,
              children: [
                OnAnimationBuilder(
                  listenTo: animation,
                  builder: (animate) => Transform.rotate(
                    angle: animate.fromTween(
                      (currentValue) => Tween(
                        begin: currentValue ?? 0,
                        end: (currentValue ?? 0) + 2 * 3.14 / 60,
                      ),
                    )!,
                    alignment: Alignment.bottomCenter,
                    child: secondRod,
                  ),
                ),
                OnAnimationBuilder(
                    listenTo: animation,
                    builder: (animate) => Transform.rotate(
                      angle: animate.fromTween(
                        (currentValue) => Tween(
                          begin: currentValue ?? 0,
                          end: (currentValue ?? 0) + 2 * 3.14 / 60 / 60,
                        ),
                      )!,
                      alignment: Alignment.bottomCenter,
                      child: minuteRod,
                  ),
                ),
                OnAnimationBuilder(
                  listenTo: animation,
                  builder: (animate) => Transform.rotate(
                      angle: animate.fromTween(
                        (currentValue) => Tween(
                          begin: currentValue ?? 0,
                          end: (currentValue ?? 0) + 2 * 3.14 / 60 / 60 / 60,
                        ),
                      )!,
                      alignment: Alignment.bottomCenter,
                      child: hourRod,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

This is the output of this example:

![image](https://user-images.githubusercontent.com/38536986/116422545-c3686b00-a837-11eb-94d7-a1b934c3db2a.png)

## Use of Flutter's transition widgets

You can use built-in flutter's `FooTransition` widget such as `PositionedTransition`, `AlignTransition` ..:

The following example is the same example of `PositionedTransition` in flutter docs rewritten using states_rebuilder. ([Link here](https://api.flutter.dev/flutter/widgets/PositionedTransition-class.html)).

```dart
 OnAnimationBuilder(
  listenTo: animation,
  builder: (_) => PositionedTransition(
     rect: RelativeRectTween(
       begin: RelativeRect.fromSize( const Rect.fromLTWH(0, 0, smallLogo, smallLogo), biggest),
       end: RelativeRect.fromSize(Rect.fromLTWH(biggest.width - bigLogo,
               biggest.height - bigLogo, bigLogo, bigLogo),biggest),
     ).animate(animation.curvedAnimation),
     child: const Padding(padding: EdgeInsets.all(8), child: FlutterLogo()),
   ),
 ),
```
## InjectedAnimation methods
### curvedAnimation
Get default animation with `Tween<double>(begin:0.0, end:1.0)` and with the defined curve,

Used with Flutter's widgets that end with Transition (ex SlideTransition RotationTransition)
### triggerAnimation
Used to tart animation.

If animation is completed (stopped at the end) then the animation is reversed, and if the animation is dismissed (stopped at the beginning) then the animation is forwarded.

You can start animation conventionally using `controller!.forward` for example.

It returns Future that resolves when the started animation ends.

Update `OnAnimationBuilder` widgets listening the this animation

Has similar effect as when the widget rebuilds to invoke implicit animation

It returns Future that resolves when the started animation ends.
### refresh

## staggered Animation

You can specify for each animate value, its onw `curve` and `reverseCurve` using `setCurve` and `setReverseCurve`.

This is the same example as in [Flutter docs for staggered animation](https://flutter.dev/docs/development/ui/animations/staggered-animations):


```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final animation = RM.injectAnimation(
  duration: const Duration(milliseconds: 2000),
  repeats: 2,
  shouldReverseRepeats: true,
);

class StaggerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staggered Animation'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          animation.triggerAnimation();
        },
        child: Center(
          child: Container(
            width: 300.0,
            height: 300.0,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            child: OnAnimationBuilder(
                listenTo: animation,
                builder: (animate) => Container(
                    padding: animate
                        .setCurve(Interval(0.250, 0.375, curve: Curves.ease))
                        .formTween(
                          (_) => EdgeInsetsTween(
                            begin: const EdgeInsets.only(bottom: 16.0),
                            end: const EdgeInsets.only(bottom: 75.0),
                          ),
                        ),
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: animate
                          .setCurve(Interval(0.0, 0.100, curve: Curves.ease))
                          .formTween(
                            (_) => Tween<double>(begin: 0.0, end: 1.0),
                          )!,
                      child: Container(
                        width: animate
                            .setCurve(Interval(0.125, 0.250, curve: Curves.ease))
                            .formTween(
                              (_) => Tween<double>(begin: 50.0, end: 150.0),
                              'width',
                            )!,
                        height: animate
                            .setCurve(Interval(0.250, 0.375, curve: Curves.ease))
                            .formTween(
                              (_) => Tween<double>(begin: 50.0, end: 150.0),
                              'height',
                            )!,
                        decoration: BoxDecoration(
                          color: animate
                              .setCurve(Interval(0.500, 0.750, curve: Curves.ease))
                              .formTween(
                                (_) => ColorTween(
                                  begin: Colors.indigo[100],
                                  end: Colors.orange[400],
                                ),
                              ),
                          border: Border.all(
                            color: Colors.indigo[300]!,
                            width: 3.0,
                          ),
                          borderRadius: animate
                              .setCurve(Interval(0.375, 0.500, curve: Curves.ease))
                              .formTween(
                                (_) => BorderRadiusTween(
                                  begin: BorderRadius.circular(4.0),
                                  end: BorderRadius.circular(75.0),
                                ),
                              ),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: StaggerDemo()));
}
```

Even with implicit animation you stagger it.

This is the same example rewritten using implicit animation:

```dart

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final animation = RM.injectAnimation(
  duration: const Duration(milliseconds: 2000),
);
bool isSelected = true;

class StaggerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staggered Animation'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          isSelected = !isSelected;
          animation.refresh();
        },
        child: Center(
          child: Container(
            width: 300.0,
            height: 300.0,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            child: Container(
              width: 300.0,
              height: 300.0,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              child: OnAnimationBuilder(
                  listenTo: animation,
                  builder: (animate) => Container(
                      padding: animate
                          .setCurve(
                            Interval(0.250, 0.375, curve: Curves.ease),
                          )
                          .call(
                            isSelected
                                ? const EdgeInsets.only(bottom: 16.0)
                                : const EdgeInsets.only(bottom: 75.0),
                          ),
                      alignment: Alignment.bottomCenter,
                      child: Opacity(
                        opacity: animate
                            .setCurve(
                              Interval(0.0, 0.800, curve: Curves.ease),
                            )
                            .call(isSelected ? 0.0 : 1.0)!,
                        child: Container(
                          width: animate
                              .setCurve(
                                Interval(0.125, 0.250, curve: Curves.ease),
                              )
                              .call(isSelected ? 50.0 : 150.0, 'width')!,
                          height: animate
                              .setCurve(
                                Interval(0.250, 0.375, curve: Curves.ease),
                              )
                              .call(isSelected ? 50.0 : 150.0, 'hight')!,
                          decoration: BoxDecoration(
                            color: animate
                                .setCurve(
                                  Interval(0.500, 0.750, curve: Curves.ease),
                                )
                                .call(
                                  isSelected
                                      ? Colors.indigo[100]
                                      : Colors.orange[400],
                                ),
                            border: Border.all(
                              color: Colors.indigo[300]!,
                              width: 3.0,
                            ),
                            borderRadius: animate
                                .setCurve(
                                  Interval(0.375, 0.500, curve: Curves.ease),
                                )
                                .call(
                                  isSelected
                                      ? BorderRadius.circular(4.0)
                                      : BorderRadius.circular(75.0),
                                ),
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: StaggerDemo()));
}
```

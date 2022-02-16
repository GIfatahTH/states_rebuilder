import 'package:ex_006_3_animation/tab_bar_navigator.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'animated_container.dart';
import 'explicit_animation.dart';
import 'implicit_staggered_animation.dart';
import 'staggered_animation.dart';
import 'timer_demo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Injected Animation'),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => RM.navigate.to(AnimatedContainerDemo()),
                child: Text('Implicit Animation demo'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => RM.navigate.to(ExplicitAnimationDemo()),
                child: Text('Explicit Animation demo'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => RM.navigate.to(StaggeredAnimationDemo()),
                child: Text('Staggered Animation demo'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => RM.navigate.to(ImplicitStaggeredDemo()),
                child: Text('Implicit Staggered Animation demo'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => RM.navigate.to(TimerApp()),
                child: Text('Timer app'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => RM.navigate.to(TabBarNavigator()),
                child: Text('Custom Tab bar'),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

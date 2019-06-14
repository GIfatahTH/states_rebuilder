import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../pages/first_alternative.dart';
import '../pages/second_alternative.dart';
import '../pages/third_alternative.dart';

// enum is preferred over String to name your `tag` for big projects.
// The name of the enums is of your choice. You can have many enums.

// -- Conventionally for each of your BloCs you define a corresponding enum.
// -- For very large projects you can make all your enums in a single file.

enum CounterState { firstAlternative, total }

// Our logic class a counter variable and a method to increment it.
//
// It must extend from StatesRebuilder.
class CounterBloc extends StatesRebuilder {
  TabController tabController;
  int _counter1 = 0;
  int _counter2 = 0;

  int get counter1 => _counter1;
  int get counter2 => _counter2;
  int get total => _counter1 + _counter2;

  initState(State state) {
    tabController =
        TabController(vsync: state as TickerProvider, length: choices.length);
  }

  void nextPage(int delta) {
    final int newIndex = tabController.index + delta;
    if (newIndex < 0 || newIndex >= tabController.length) return;
    tabController.animateTo(newIndex);
  }

  dispose() {
    tabController.dispose();
    print("tab Controller is disposed");
  }

  void increment1() {
    // Increment the counter
    _counter1++;
    // First alternative.
    // Widgets with these stateIDs will rebuild to reflect the new counter value.
    rebuildStates([CounterState.firstAlternative, CounterState.total]);
  }

  void increment2(String tagID) {
    // Increment the counter
    _counter2++;

    // Second alternative.
    // Widgets from which the increment2 method is called will rebuild.
    // You can mix states and stateIDs
    rebuildStates([null, tagID, null, CounterState.total, null]);
  }

  void increment3() {
    // increment the counter
    _counter1++;
    // The third alternative

    // `rebuildStates()` with no parameter: All widgets that are wrapped with `StateBuilder` and
    // are given `tag` will rebuild to reflect the new counter value.
    //
    // you get a similar behavior like in scoped_model or provider packages
    rebuildStates();
    // in this particular example we have two widgets that have
    // a tag (CounterState.myCounter, and CounterState.total)
  }
}

final List<Widget> choices = [
  FirstAlternative(),
  SecondAlternative(),
  ThirdAlternative(),
];

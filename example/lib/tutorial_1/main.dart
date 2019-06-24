import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import './enums/tag_enums.dart';
import './logic/viewModels/main_model.dart';
import './ui/views/counter_view_injector.dart';
import './ui/views/counter_view_injector.generic.dart';
import './ui/views/double_counter.dart';
import './ui/views/double_counter_share.dart';
import './ui/views/double_counter_share_the_same_view.dart';

import 'ui/views/counter_view_global.dart';

main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<MainModel>(
      models: [() => MainModel()],
      builder: (context, model) => MaterialApp(
            home: StateWithMixinBuilder<SingleTickerProviderStateMixin>(
                mixinWith: MixinWith.singleTickerProviderStateMixin,
                initState: (_, __, ticker) =>
                    model.initState(ticker, tabs.length),
                dispose: (_, __, ___) => model.dispose(),
                builder: (_, __) => _Scaffold()),
          ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final model = Injector.get<MainModel>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StateBuilder(
          viewModels: [model],
          tag: MainTag.appBar,
          builder: (_, __) => Text(tabTitles[model.tabController.index]),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Theme(
            data: Theme.of(context).copyWith(accentColor: Colors.white),
            child: Container(
              height: 48.0,
              alignment: Alignment.center,
              child: TabPageSelector(controller: model.tabController),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: model.tabController,
        children: tabs,
      ),
    );
  }
}

List<Widget> tabs = [
  CounterViewGlobal(),
  CounterViewInjector(),
  CounterViewInjectorGeneric(),
  DoubleCounter(),
  DoubleCounterShare(),
  DoubleCounterShareTheSameView()
];

List<String> tabTitles = [
  "Global instance of ViewModel",
  "Using Injector to provide ViewModel",
  "Injector with generic type.",
  "Double independent counter",
  "Using service to share counter value",
  "share data \nViews in the same view",
];

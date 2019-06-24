import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import './ui/views/bloc_pattern_view.dart';
import './ui/views/double_counter_share.dart';
import './ui/views/streaming_counter_view.dart';
import './ui/views/login_form_view.dart';

import 'enums/tag_enums.dart';
import 'logic/viewModels/main_model.dart';
import 'ui/views/double_counter_share_the_same_view.dart';

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
  BlocPatternView(),
  StreamingCounterView(),
  DoubleCounterShare(),
  DoubleCounterShareTheSameView(),
  LoginFormView(),
];

List<String> tabTitles = [
  "Bloc pattern",
  "Use of Streaming class",
  "share data using Streaming",
  "share data using Streaming\nin the same view",
  "Login Form"
];

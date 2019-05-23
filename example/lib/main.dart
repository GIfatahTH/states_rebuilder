import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'pages/1_rebuild_all.dart';
import 'pages/2_rebuild_one.dart';
import 'pages/3_rebuild_set.dart';
import 'pages/4_rebuild_remote.dart';
import 'pages/5_animate_all.dart';
import 'pages/6_animate_one_1.dart';
import 'pages/7_animate_one_2.dart';
import 'pages/8_animate_set.dart';
import 'pages/9_rebuildStates_performance.dart';

enum CounterGridTag { isEvenIcon }

class MainBloc extends StatesRebuilder {
  TabController tabController;
  init(TickerProvider ticker) {
    tabController = TabController(vsync: ticker, length: 9);
  }

  dispose() {
    tabController.dispose();
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grid of Counters",
      home: BlocProvider(
        bloc: MainBloc(),
        child: RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<MainBloc>(context);
    return StateWithMixinBuilder(
      mixinWith: MixinWith.singleTickerProviderStateMixin,
      initState: (_, __, ticker) => bloc.init(ticker),
      dispose: (_, __, ___) => bloc.dispose(),
      builder: (
        _,
        __,
      ) =>
          Scaffold(
            appBar: AppBar(
              title: Text("Counter Grid"),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.white),
                  child: Container(
                    height: 48.0,
                    alignment: Alignment.center,
                    child: TabPageSelector(controller: bloc.tabController),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: bloc.tabController,
              children: <Widget>[
                RebuildAllExample(),
                RebuildOneExample(),
                RebuildSetExample(),
                RebuildRemoteExample(),
                AnimateAllExample(),
                AnimateOneExample1(),
                AnimateOneExample2(),
                AnimateSetExample(),
                RebuildStatesPerformanceExample(),
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum MainState { firstAlternative }

class MainBloc extends StatesRebuilder {
  TabController _tabController;

  initState(State state) {
    mainBloc._tabController =
        TabController(vsync: state as TickerProvider, length: choices.length);
  }

  void _nextPage(int delta) {
    final int newIndex = _tabController.index + delta;
    if (newIndex < 0 || newIndex >= _tabController.length) return;
    _tabController.animateTo(newIndex);
  }

  dispose() {
    _tabController.dispose();
  }
}

final mainBloc = MainBloc();

class AppBarBottomSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StateBuilder(
          withTickerProvider: true,
          initState: (state) => mainBloc.initState(state),
          dispose: (_) => mainBloc.dispose(),
          builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('AppBar Bottom Widget'),
                  leading: IconButton(
                    tooltip: 'Previous choice',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      mainBloc._nextPage(-1);
                    },
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      tooltip: 'Next choice',
                      onPressed: () {
                        mainBloc._nextPage(1);
                      },
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48.0),
                    child: Theme(
                      data:
                          Theme.of(context).copyWith(accentColor: Colors.white),
                      child: Container(
                        height: 48.0,
                        alignment: Alignment.center,
                        child: TabPageSelector(
                            controller: mainBloc._tabController),
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  controller: mainBloc._tabController,
                  children: choices,
                ),
              )),
    );
  }
}

final List<Widget> choices = [
  TabBarView1(),
  TabBarView2(),
];

class TabBarView1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('You have pushed the button this many times:'),
        Divider(),
        Text('The first alternative'),

        // First Alternative:
        // -- Wrap the Text widget with StateBuilder widget and give it and id of your choice.
        // -- Declare the blocs where you want the state to be available.
        StateBuilder(
          stateID: MainState.firstAlternative,
          blocs: [mainBloc],
          builder: (State state) => Text(
                mainBloc.counter1.toString(),
                style: Theme.of(state.context).textTheme.display1,
              ),
        ),

        // The first method is mainly useful if you want to increment the counter from other widget
        IncrementFromOtheWidget(),
      ],
    );
  }
}

class TabBarView2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  runApp(AppBarBottomSample());
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  final injectedTab = RM.injectPageTab(
    initialIndex: 2,
    length: 5,
  );
  final screens = [
    Text('TabView0'),
    Text('TabView1'),
    Text('TabView2'),
    Text('TabView3'),
    Text('TabView4'),
  ];
  final tabs = [
    Text('Tab0'),
    Text('Tab1'),
    Text('Tab2'),
    Text('Tab3'),
    Text('Tab4'),
  ];
  testWidgets(
    'injectedTab basic functionality',
    (tester) async {
      int numberOfRebuild = 0;
      late int currentIndex;

      final widget = MaterialApp(
        home: Scaffold(
          body: OnTabBuilder(
            listenTo: injectedTab,
            builder: (index) {
              numberOfRebuild++;
              currentIndex = index;
              return TabBarView(
                controller: injectedTab.tabController,
                children: screens,
              );
            },
          ),
          bottomNavigationBar: OnTabBuilder(
            listenTo: injectedTab,
            builder: (index) => TabBar(
              controller: injectedTab.tabController,
              tabs: tabs,
            ),
          ),
        ),
      );
      //
      await tester.pumpWidget(widget);
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Tab2'), findsOneWidget);
      expect(numberOfRebuild, 1);
      expect(currentIndex, 2);
      //
      await tester.tap(find.text('Tab4'));
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Tab4'), findsOneWidget);
      expect(numberOfRebuild, 2);
      expect(currentIndex, 4);
      //
      await tester.tap(find.text('Tab0'));
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Tab0'), findsOneWidget);
      expect(numberOfRebuild, 3);
      expect(currentIndex, 0);
      //
      await tester.tap(find.text('Tab0'));
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Tab0'), findsOneWidget);
      expect(numberOfRebuild, 3);
      expect(currentIndex, 0);
      //
      injectedTab.index = 3;
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Tab3'), findsOneWidget);
      expect(numberOfRebuild, 4);
      expect(currentIndex, 3);
    },
  );
  testWidgets(
    'InjectedTab.animateTo works',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: injectedTab.rebuild.onTab(
            (index) {
              return TabBarView(
                controller: injectedTab.tabController,
                children: screens,
              );
            },
          ),
          bottomNavigationBar: injectedTab.rebuild.onTab(
            (index) => TabBar(
              controller: injectedTab.tabController,
              tabs: tabs,
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Tab2'), findsOneWidget);
      expect(injectedTab.previousIndex, 2);
      expect(injectedTab.indexIsChanging, false);
      injectedTab.animateTo(1);
      await tester.pump();
      expect(injectedTab.indexIsChanging, true);
      await tester.pumpAndSettle();
      expect(find.text('TabView1'), findsOneWidget);
      expect(find.text('Tab1'), findsOneWidget);
      expect(injectedTab.previousIndex, 2);
      expect(injectedTab.indexIsChanging, false);
    },
  );

  testWidgets(
    'OnTabBuilder',
    (tester) async {
      final injectedTab = RM.injectPageTab(
        length: 5,
      );
      late int currentIndex;

      final widget = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: OnTabBuilder(
              listenTo: injectedTab,
              builder: (index) => Text('Tab $index is displayed'),
            ),
          ),
          body: OnTabBuilder(
            listenTo: injectedTab,
            builder: (_) {
              return TabBarView(
                controller: injectedTab.tabController,
                children: screens,
              );
            },
          ),
          bottomNavigationBar: OnTabBuilder(
            listenTo: injectedTab,
            builder: (_) {
              currentIndex = injectedTab.index;
              return TabBar(
                controller: injectedTab.tabController,
                tabs: tabs,
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Tab0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      expect(currentIndex, 0);
      //
      await tester.drag(find.text('TabView0'), Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('TabView1'), findsOneWidget);
      expect(find.text('Tab1'), findsOneWidget);
      expect(find.text('Tab 1 is displayed'), findsOneWidget);
      expect(currentIndex, 1);
    },
  );

  testWidgets(
    'Test when only PageController is defined',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: OnBuilder(
              listenTo: injectedTab,
              builder: () => Text('Tab ${injectedTab.index} is displayed'),
            ),
          ),
          body: OnReactive(
            () => PageView(
              controller: injectedTab.pageController,
              children: screens.getRange(0, injectedTab.length).toList(),
            ),
          ),
          bottomNavigationBar: OnReactive(
            () => Row(
              children: tabs
                  .getRange(0, injectedTab.length)
                  .toList()
                  .asMap()
                  .map(
                    (i, e) => MapEntry(
                      i,
                      InkWell(
                        onTap: () {
                          injectedTab.index = i;
                        },
                        child: injectedTab.index == i
                            ? Text('Selected tab: $i')
                            : e,
                      ),
                    ),
                  )
                  .values
                  .toList(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Selected tab: 2'), findsOneWidget);
      expect(find.text('Tab 2 is displayed'), findsOneWidget);
      //
      await tester.drag(find.text('TabView2'), Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);

      //
      await tester.tap(find.text('Tab0'));
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      //
      injectedTab.animateTo(4);
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      //
      injectedTab.animateTo(4);
      await tester.pump();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);

      //
      injectedTab.animateTo(1, duration: Duration.zero);
      await tester.pump();
      expect(find.text('TabView1'), findsOneWidget);
      expect(find.text('Selected tab: 1'), findsOneWidget);
      expect(find.text('Tab 1 is displayed'), findsOneWidget);
      injectedTab.previousView();
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      injectedTab.previousView();
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      //
      injectedTab.animateTo(3, duration: Duration.zero);
      await tester.pump();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      //
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      //
      injectedTab.length = 4;
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      await tester.tap(find.text('Tab2'));
      await tester.pumpAndSettle();
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Selected tab: 2'), findsOneWidget);
      expect(find.text('Tab 2 is displayed'), findsOneWidget);
      await tester.drag(find.text('TabView2'), Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      //

      //
      //
      injectedTab.length = 5;
      await tester.pump();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      //
      await tester.tap(find.text('Tab2'));
      await tester.pumpAndSettle();
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Selected tab: 2'), findsOneWidget);
      expect(find.text('Tab 2 is displayed'), findsOneWidget);
      await tester.drag(find.text('TabView2'), Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
    },
  );

  testWidgets(
    'Test when only TabController is defined',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: OnBuilder(
              listenTo: injectedTab,
              builder: () => Text('Tab ${injectedTab.index} is displayed'),
            ),
          ),
          body: OnTabBuilder(
            listenTo: injectedTab,
            builder: (_) {
              return TabBarView(
                controller: injectedTab.tabController,
                children: screens.getRange(0, injectedTab.length).toList(),
              );
            },
          ),
          bottomNavigationBar: OnReactive(
            () => TabBar(
              controller: injectedTab.tabController,
              tabs: tabs
                  .getRange(0, injectedTab.length)
                  .toList()
                  .asMap()
                  .map(
                    (i, e) => MapEntry(
                      i,
                      injectedTab.index == i ? Text('Selected tab: $i') : e,
                    ),
                  )
                  .values
                  .toList(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Selected tab: 2'), findsOneWidget);
      expect(find.text('Tab 2 is displayed'), findsOneWidget);
      //
      await tester.drag(find.text('TabView2'), Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);

      //
      await tester.tap(find.text('Tab0'));
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      //
      injectedTab.animateTo(4);
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      //
      injectedTab.animateTo(4);
      await tester.pump();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);

      //
      injectedTab.animateTo(1, duration: Duration.zero);
      await tester.pumpAndSettle();
      expect(find.text('TabView1'), findsOneWidget);
      expect(find.text('Selected tab: 1'), findsOneWidget);
      expect(find.text('Tab 1 is displayed'), findsOneWidget);
      injectedTab.previousView();
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      injectedTab.previousView();
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      //
      injectedTab.animateTo(3, duration: Duration.zero);
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      //
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      //
      injectedTab.length = 4;
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      expect(find.text('Tab4'), findsNothing);
      // await tester.tap(find.text('Tab2'));
      // await tester.pumpAndSettle();
      // expect(find.text('TabView2'), findsOneWidget);
      // expect(find.text('Selected tab: 2'), findsOneWidget);
      // expect(find.text('Tab 2 is displayed'), findsOneWidget);
      // await tester.drag(find.text('TabView2'), Offset(-400, 0));
      // await tester.pumpAndSettle();
      // expect(find.text('TabView3'), findsOneWidget);
      // expect(find.text('Selected tab: 3'), findsOneWidget);
      // expect(find.text('Tab 3 is displayed'), findsOneWidget);
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      //
      injectedTab.length = 5;
      await tester.pumpAndSettle();
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      expect(find.text('TabView3'), findsOneWidget);

      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      expect(find.text('TabView4'), findsOneWidget);
      //
      await tester.tap(find.text('Tab2'));
      await tester.pumpAndSettle();
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Selected tab: 2'), findsOneWidget);
      expect(find.text('Tab 2 is displayed'), findsOneWidget);
      await tester.drag(find.text('TabView2'), Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
    },
  );

  testWidgets(
    'Test when both PageController and TabController are defined',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: OnBuilder(
              listenTo: injectedTab,
              builder: () => Text('Tab ${injectedTab.index} is displayed'),
            ),
          ),
          body: OnReactive(
            () {
              return PageView(
                controller: injectedTab.pageController,
                children: screens.getRange(0, injectedTab.length).toList(),
              );
            },
          ),
          bottomNavigationBar: OnTabBuilder(
            listenTo: injectedTab,
            builder: (index) => TabBar(
              controller: injectedTab.tabController,
              tabs: tabs
                  .getRange(0, injectedTab.length)
                  .toList()
                  .asMap()
                  .map(
                    (i, e) => MapEntry(
                      i,
                      index == i ? Text('Selected tab: $i') : e,
                    ),
                  )
                  .values
                  .toList(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Selected tab: 2'), findsOneWidget);
      expect(find.text('Tab 2 is displayed'), findsOneWidget);
      //
      await tester.drag(find.text('TabView2'), Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);

      //
      await tester.tap(find.text('Tab0'));
      await tester.pumpAndSettle();
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      expect(find.text('TabView0'), findsOneWidget);
      //
      injectedTab.animateTo(4);
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      //
      injectedTab.animateTo(4);
      await tester.pump();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);

      //
      injectedTab.animateTo(1);
      await tester.pumpAndSettle();
      expect(find.text('TabView1'), findsOneWidget);
      expect(find.text('Selected tab: 1'), findsOneWidget);
      expect(find.text('Tab 1 is displayed'), findsOneWidget);
      injectedTab.previousView();
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      injectedTab.previousView();
      await tester.pumpAndSettle();
      expect(find.text('TabView0'), findsOneWidget);
      expect(find.text('Selected tab: 0'), findsOneWidget);
      expect(find.text('Tab 0 is displayed'), findsOneWidget);
      //
      injectedTab.animateTo(3);
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      //
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView4'), findsOneWidget);
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      //
      injectedTab.length = 4;
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      expect(find.text('Tab4'), findsNothing);
      // await tester.tap(find.text('Tab2'));
      // await tester.pumpAndSettle();
      // expect(find.text('TabView2'), findsOneWidget);
      // expect(find.text('Selected tab: 2'), findsOneWidget);
      // expect(find.text('Tab 2 is displayed'), findsOneWidget);
      // await tester.drag(find.text('TabView2'), Offset(-400, 0));
      // await tester.pumpAndSettle();
      // expect(find.text('TabView3'), findsOneWidget);
      // expect(find.text('Selected tab: 3'), findsOneWidget);
      // expect(find.text('Tab 3 is displayed'), findsOneWidget);
      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      //
      injectedTab.length = 5;
      await tester.pumpAndSettle();
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
      expect(find.text('TabView3'), findsOneWidget);

      injectedTab.nextView();
      await tester.pumpAndSettle();
      expect(find.text('Selected tab: 4'), findsOneWidget);
      expect(find.text('Tab 4 is displayed'), findsOneWidget);
      expect(find.text('TabView4'), findsOneWidget);
      //
      await tester.tap(find.text('Tab2'));
      await tester.pumpAndSettle();
      expect(find.text('TabView2'), findsOneWidget);
      expect(find.text('Selected tab: 2'), findsOneWidget);
      expect(find.text('Tab 2 is displayed'), findsOneWidget);
      await tester.drag(find.text('TabView2'), Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('TabView3'), findsOneWidget);
      expect(find.text('Selected tab: 3'), findsOneWidget);
      expect(find.text('Tab 3 is displayed'), findsOneWidget);
    },
  );
}

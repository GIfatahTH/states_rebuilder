import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';

void main() {
  final injectedTab = RM.injectTab(
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
          body: On.tab(
            () {
              numberOfRebuild++;
              currentIndex = injectedTab.index;
              return TabBarView(
                controller: injectedTab.controller,
                children: screens,
              );
            },
          ).listenTo(injectedTab),
          bottomNavigationBar: On.tab(
            () => TabBar(
              controller: injectedTab.controller,
              tabs: tabs,
            ),
          ).listenTo(injectedTab),
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
            () {
              return TabBarView(
                controller: injectedTab.controller,
                children: screens,
              );
            },
          ),
          bottomNavigationBar: injectedTab.rebuild.onTab(
            () => TabBar(
              controller: injectedTab.controller,
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
      final injectedTab = RM.injectTab(
        length: 5,
      );
      late int currentIndex;

      final widget = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: On.tab(
              () => Text('Tab ${injectedTab.index} is displayed'),
            ).listenTo(injectedTab),
          ),
          body: OnTabBuilder(
            listenTo: injectedTab,
            builder: () {
              return TabBarView(
                controller: injectedTab.controller,
                children: screens,
              );
            },
          ),
          bottomNavigationBar: OnTabBuilder(
            listenTo: injectedTab,
            builder: () {
              currentIndex = injectedTab.index;
              return TabBar(
                controller: injectedTab.controller,
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
}

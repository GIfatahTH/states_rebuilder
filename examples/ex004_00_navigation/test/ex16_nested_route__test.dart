import 'package:ex_006_5_navigation/ex16_nested_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dashboard = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Dashboard' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(Dash),
    'text': find.byType(Dash),
  };
  final about = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'About' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(About),
    'text': find.text('About Page'),
  };
  final support = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Support' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(Support),
    'text': find.text('Support Page'),
  };
  void checkMainMenu(Map<String, Finder>? finder) {
    for (var f in [dashboard, about, support]) {
      if (f == finder) {
        expect(f['menu'], findsOneWidget);
        expect(f['page'], findsOneWidget);
        expect(f['text'], findsOneWidget);
      } else {
        expect(f['menu'], findsNothing);
        expect(f['page'], findsNothing);
        expect(f['text'], findsNothing);
      }
    }
  }

  final home = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Home' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(DashHome),
    'text': find.text('DashHome'),
  };
  final invoices = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Invoices' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(Invoices),
    'text': find.byType(Invoices),
  };
  final team = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Team' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(Team),
    'text': find.text('Team Page'),
  };
  void checkSubMenu1(Map<String, Finder>? finder) {
    for (var f in [home, invoices, team]) {
      if (f == finder) {
        expect(f['menu'], findsOneWidget);
        expect(f['page'], findsOneWidget);
        expect(f['text'], findsOneWidget);
      } else {
        expect(f['menu'], findsNothing);
        expect(f['page'], findsNothing);
        expect(f['text'], findsNothing);
      }
    }
  }

  final daily = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Daily' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(DailyInvoices),
    'text': find.text('Daily Invoices'),
  };
  final weekly = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Weekly' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(WeeklyInvoices),
    'text': find.text('Weekly Invoices'),
  };
  final monthly = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Monthly' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(MonthlyInvoices),
    'text': find.text('Monthly Invoices'),
  };

  void checkSubMenu2(Map<String, Finder>? finder) {
    for (var f in [daily, weekly, monthly]) {
      if (f == finder) {
        expect(f['menu'], findsOneWidget);
        expect(f['page'], findsOneWidget);
        expect(f['text'], findsOneWidget);
      } else {
        expect(f['menu'], findsNothing);
        expect(f['page'], findsNothing);
        expect(f['text'], findsNothing);
      }
    }
  }

  testWidgets(
    'Check main menu',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      checkMainMenu(about);
      checkSubMenu1(null);
      checkSubMenu2(null);
      //
      await tester.tap(find.text('Support'));
      await tester.pumpAndSettle();
      checkMainMenu(support);
      checkSubMenu1(null);
      checkSubMenu2(null);
    },
  );

  testWidgets(
    'Check first sub menu',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //
      await tester.tap(find.text('Invoices'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      await tester.tap(find.text('Team'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(team);
      checkSubMenu2(null);
      //
      await tester.tap(find.text('Invoices'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //
      await tester.tap(find.text('Invoices'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      checkMainMenu(about);
      checkSubMenu1(null);
      checkSubMenu2(null);
    },
  );

  testWidgets(
    'Check second sub menu',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //
      await tester.tap(find.text('Invoices'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(weekly);
      //
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(monthly);
      //
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      await tester.tap(find.text('Team'));
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(team);
      checkSubMenu2(null);
    },
  );

  testWidgets(
    'Check main menu. Deep link',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //
      navigator.deepLinkTest('/about');
      await tester.pumpAndSettle();
      checkMainMenu(about);
      checkSubMenu1(null);
      checkSubMenu2(null);
      //
      navigator.deepLinkTest('/support');
      await tester.pumpAndSettle();
      checkMainMenu(support);
      checkSubMenu1(null);
      checkSubMenu2(null);
    },
  );

  testWidgets(
    'Check first sub menu. Deep link',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //
      navigator.deepLinkTest('/dashboard/invoices');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      navigator.deepLinkTest('/dashboard/team');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(team);
      checkSubMenu2(null);
      //
      navigator.deepLinkTest('/dashboard/invoices');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      navigator.deepLinkTest('/dashboard');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //

      navigator.deepLinkTest('/dashboard/invoices');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      navigator.deepLinkTest('/about');
      await tester.pumpAndSettle();
      checkMainMenu(about);
      checkSubMenu1(null);
      checkSubMenu2(null);
    },
  );

  testWidgets(
    'Check second sub menu. Deep link',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //
      navigator.deepLinkTest('/dashboard/invoices');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      navigator.deepLinkTest('/dashboard/invoices/weekly');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(weekly);
      //
      navigator.deepLinkTest('/dashboard/invoices/monthly');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(monthly);
      //
      navigator.deepLinkTest('/dashboard/invoices/daily');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      navigator.deepLinkTest('/dashboard/team');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(team);
      checkSubMenu2(null);
    },
  );

  testWidgets(
    'Check unknown deep link',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      checkSubMenu2(null);
      //
      navigator.deepLinkTest('/dashboard1');
      await tester.pumpAndSettle();
      expect(dashboard['menu'], findsOneWidget);
      expect(dashboard['page'], findsNothing);
      checkSubMenu1(null);
      checkSubMenu2(null);
      expect(find.text('/dashboard1 not found'), findsOneWidget);
      //
      navigator.deepLinkTest('/dashboard/1/2/3');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(null);
      checkSubMenu2(null);
      expect(find.text('/dashboard/1/2/3 not found'), findsOneWidget);
      //
      navigator.deepLinkTest('/about1');
      await tester.pumpAndSettle();
      expect(about['menu'], findsOneWidget);
      expect(about['page'], findsNothing);
      checkSubMenu1(null);
      checkSubMenu2(null);
      expect(find.text('/about1 not found'), findsOneWidget);
      //
      navigator.deepLinkTest('/about/1/2/3');
      await tester.pumpAndSettle();
      expect(about['menu'], findsOneWidget);
      expect(about['page'], findsNothing);
      checkSubMenu1(null);
      checkSubMenu2(null);
      expect(find.text('/about/1/2/3 not found'), findsOneWidget);
      //
      navigator.deepLinkTest('/dashboard/invoices1');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      expect(invoices['menu'], findsOneWidget);
      expect(invoices['page'], findsNothing);
      checkSubMenu2(null);
      expect(find.text('/dashboard/invoices1 not found'), findsOneWidget);
      //
      navigator.deepLinkTest('/dashboard/invoices/1/2/3');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      expect(invoices['menu'], findsOneWidget);
      expect(invoices['page'], findsOneWidget);
      checkSubMenu2(null);
      expect(find.text('/dashboard/invoices/1/2/3 not found'), findsOneWidget);
      //
      navigator.deepLinkTest('/dashboard/invoices/monthly1');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      expect(monthly['menu'], findsOneWidget);
      expect(monthly['page'], findsNothing);
      expect(
          find.text('/dashboard/invoices/monthly1 not found'), findsOneWidget);
      //
      navigator.deepLinkTest('/dashboard/invoices/monthly/1/2/3');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      expect(monthly['menu'], findsOneWidget);
      expect(monthly['page'], findsNothing);
      expect(
        find.text('/dashboard/invoices/monthly/1/2/3 not found'),
        findsOneWidget,
      );
    },
  );
}

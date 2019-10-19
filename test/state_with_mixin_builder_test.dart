import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  group("should throw assertion error, ", () {
    testWidgets(
        "if is mixin with singleTickerProviderStateMixin and initState and dispose are not defined",
        (WidgetTester tester) async {
      expect(
          () => StateWithMixinBuilder(
                mixinWith: MixinWith.singleTickerProviderStateMixin,
                builder: (context, tagId) => Container(),
              ),
          throwsAssertionError);
    });
    testWidgets(
        "if is mixin with TickerProviderStateMixin and initState and dispose are not defined",
        (WidgetTester tester) async {
      expect(
          () => StateWithMixinBuilder(
                mixinWith: MixinWith.tickerProviderStateMixin,
                builder: (context, tagId) => Container(),
              ),
          throwsAssertionError);
    });

    testWidgets(
        "if is mixin with WidgetsBindingObserver and initState and dispose are not defined",
        (WidgetTester tester) async {
      expect(
          () => StateWithMixinBuilder(
                mixinWith: MixinWith.widgetsBindingObserver,
                builder: (context, tagId) => Container(),
              ),
          throwsAssertionError);
    });
  });
  testWidgets(
      "should not throw error if is mixin with AutomaticKeepAliveClientMixin and initState and dispose are not defined",
      (WidgetTester tester) async {
    expect(
        () => StateWithMixinBuilder(
              mixinWith: MixinWith.automaticKeepAliveClientMixin,
              builder: (context, tagId) => Container(),
            ),
        isA<Function>());
  });

  group("should SingleTickerProviderStateMixin be instantiated, ", () {
    testWidgets("case not generic type is provided",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      await tester.pumpWidget(
        StateWithMixinBuilder(
          mixinWith: MixinWith.singleTickerProviderStateMixin,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          dispose: (context, tagID, ticker) => null,
          builder: (context, tagId) => Container(),
        ),
      );
      expect(_ticker, isA<SingleTickerProviderStateMixin>());
      expect(_tagID, isNull);
    });

    testWidgets("case the generic type is provided",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      await tester.pumpWidget(
        StateWithMixinBuilder<SingleTickerProviderStateMixin>(
          mixinWith: MixinWith.singleTickerProviderStateMixin,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          dispose: (context, tagID, ticker) => null,
          builder: (context, tagId) => Container(),
        ),
      );
      expect(_ticker, isA<SingleTickerProviderStateMixin>());
      expect(_tagID, isNull);
    });

    testWidgets(
        "default tag should created case viewModel provided with no tag",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      final vm = ViewModel();
      int rebuildCount = 0;
      await tester.pumpWidget(
        StateWithMixinBuilder(
          mixinWith: MixinWith.singleTickerProviderStateMixin,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          viewModels: [vm],
          dispose: (context, tagID, ticker) => null,
          builder: (context, tagId) {
            rebuildCount++;
            return Container();
          },
        ),
      );
      expect(_ticker, isA<SingleTickerProviderStateMixin>());
      expect(_tagID, startsWith("#@deFau_Lt"));
      vm.rebuildStates();
      await tester.pump();
      expect(rebuildCount, equals(2));
    });
  });

  group("should TickerProviderStateMixin be instantiated, ", () {
    testWidgets("case not generic type is provided",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      await tester.pumpWidget(
        StateWithMixinBuilder(
          mixinWith: MixinWith.tickerProviderStateMixin,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          dispose: (context, tagID, ticker) => null,
          builder: (context, tagId) => Container(),
        ),
      );
      expect(_ticker, isA<TickerProviderStateMixin>());
      expect(_tagID, isNull);
    });

    testWidgets("case the generic type is provided",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      await tester.pumpWidget(
        StateWithMixinBuilder<TickerProviderStateMixin>(
          mixinWith: MixinWith.tickerProviderStateMixin,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          dispose: (context, tagID, ticker) => null,
          builder: (context, tagId) => Container(),
        ),
      );
      expect(_ticker, isA<TickerProviderStateMixin>());
      expect(_tagID, isNull);
    });
  });

  group("should WidgetsBindingObserver be instantiated, ", () {
    testWidgets("case not generic type is provided",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      await tester.pumpWidget(
        StateWithMixinBuilder(
          mixinWith: MixinWith.widgetsBindingObserver,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          dispose: (context, tagID, ticker) => null,
          didChangeAppLifecycleState: (context, tagID, appState) {},
          builder: (context, tagId) => Container(),
        ),
      );
      expect(_ticker, isA<WidgetsBindingObserver>());
      expect(_tagID, isNull);
    });

    testWidgets("case the generic type is provided",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      await tester.pumpWidget(
        StateWithMixinBuilder<WidgetsBindingObserver>(
          mixinWith: MixinWith.widgetsBindingObserver,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          dispose: (context, tagID, ticker) => null,
          builder: (context, tagId) => Container(),
        ),
      );
      expect(_ticker, isA<WidgetsBindingObserver>());
      expect(_tagID, isNull);
    });
  });

  group("should AutomaticKeepAliveClientMixin be instantiated, ", () {
    testWidgets("case not generic type is provided",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      await tester.pumpWidget(
        StateWithMixinBuilder(
          mixinWith: MixinWith.automaticKeepAliveClientMixin,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          dispose: (context, tagID, ticker) => null,
          builder: (context, tagId) => Container(),
        ),
      );
      expect(_ticker, isA<AutomaticKeepAliveClientMixin>());
      expect(_tagID, isNull);
    });

    testWidgets("case the generic type is provided",
        (WidgetTester tester) async {
      String _tagID;
      var _ticker;
      await tester.pumpWidget(
        StateWithMixinBuilder<AutomaticKeepAliveClientMixin>(
          mixinWith: MixinWith.automaticKeepAliveClientMixin,
          initState: (context, tagID, ticker) {
            _tagID = tagID;
            _ticker = ticker;
          },
          dispose: (context, tagID, ticker) => null,
          builder: (context, tagId) => Container(),
        ),
      );
      expect(_ticker, isA<AutomaticKeepAliveClientMixin>());
      expect(_tagID, isNull);
    });
  });

  testWidgets(
    "'afterMounted' and 'afterRebuild' called together",
    (WidgetTester tester) async {
      final vm = ViewModel();
      int numberOfCall = 0;
      await tester.pumpWidget(
        StateWithMixinBuilder(
          mixinWith: MixinWith.singleTickerProviderStateMixin,
          viewModels: [vm],
          initState: (_, __, ___) => null,
          dispose: (_, __, ___) => null,
          afterInitialBuild: (context, tagID, ticker) => numberOfCall++,
          afterRebuild: (context, tagID) => numberOfCall++,
          builder: (_, __) => Container(),
        ),
      );

      expect(numberOfCall, 2);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 3);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 4);
    },
  );
}

class ViewModel extends StatesRebuilder {}

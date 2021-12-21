import 'package:ex_006_5_navigation/ex15_injected_navigator_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  late NavigatorMock navigatorMock;

  setUp(() {
    navigatorMock = NavigatorMock();
    navigator.injectMock(navigatorMock);
  });
  testWidgets(
    'Test methodToTest',
    (tester) async {
      expect(navigatorMock.isBackMethodCalled, false);
      final result = methodToTest1();
      await tester.pump(const Duration(seconds: 1));
      expectLater(await result, 10);
      expect(navigatorMock.isBackMethodCalled, true);
    },
  );

  testWidgets(
    'The same test as above (run all tests to see that the tests are independent)',
    (tester) async {
      expect(navigatorMock.isBackMethodCalled, false);
      final result = methodToTest1();
      await tester.pump(const Duration(seconds: 1));
      expectLater(await result, 10);
      expect(navigatorMock.isBackMethodCalled, true);
    },
  );

  testWidgets(
    'Test methodToTest2',
    (tester) async {
      final result = methodToTest2();
      await tester.pump(const Duration(seconds: 1));
      expectLater(await result, 100);
    },
  );
}

// A better solution is to use Mockito or Mocktail libraries
// class NavigatorMock extends Mock implements InjectedNavigator{}

class NavigatorMock extends InjectedNavigator {
  bool isBackMethodCalled = false;
  @override
  void back<T extends Object>([T? result]) {
    isBackMethodCalled = true;
  }

  @override
  Future<T?> to<T extends Object?>(
    String routeName, {
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
  }) async {
    //Mock to method to return 100 after one seconds of wait
    await Future.delayed(const Duration(seconds: 1));
    return 100 as T;
  }
}

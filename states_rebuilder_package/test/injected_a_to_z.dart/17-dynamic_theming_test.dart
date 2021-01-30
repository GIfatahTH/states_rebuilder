import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final appThemes = {
  'light': ThemeData.light(),
  'dark': ThemeData.dark(),
};

final themeData = RM.inject(() => appThemes['light']);

Brightness? testBrightness;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return On.data(
      () => MaterialApp(
        theme: themeData.state,
        home: Builder(
          builder: (context) {
            testBrightness = Theme.of(context).brightness;
            return Container();
          },
        ),
      ),
    ).listenTo(themeData);
  }
}

void main() {
  testWidgets('initial build', (tester) async {
    await tester.pumpWidget(App());
    expect(testBrightness == Brightness.light, isTrue);
  });

  testWidgets('change theme to dark mode and back to light', (tester) async {
    await tester.pumpWidget(App());
    //
    themeData.state = appThemes['dark'];
    await tester.pumpAndSettle();
    expect(testBrightness == Brightness.dark, isTrue);
    //
    themeData.state = appThemes['light'];
    await tester.pumpAndSettle();
    expect(testBrightness == Brightness.light, isTrue);
  });
}

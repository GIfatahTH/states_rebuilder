import 'package:ex001_00_sync_global_and_local_state/ex_014_00_state_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Check that theme is not notified if condition is not changed',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Fetch for the weather of tody'), findsOneWidget);
      testColorTheme = null;
      weatherService.weatherRM.state = const Weather(
        condition: WeatherCondition.clear,
        location: 'Touggourt',
        temperature: 28,
      );
      await tester.pumpAndSettle();
      expect(testColorTheme, Colors.orangeAccent);
      //
      testColorTheme = null;
      weatherService.weatherRM.state = const Weather(
        condition: WeatherCondition.clear,
        location: 'Nigeria',
        temperature: 32,
      );
      await tester.pump();
      expect(testColorTheme, null);
      //
      testColorTheme = null;
      weatherService.weatherRM.state = const Weather(
        condition: WeatherCondition.cloudy,
        location: 'Nigeria',
        temperature: 32,
      );
      await tester.pump();
      expect(testColorTheme, Colors.blueGrey);
      //
      testColorTheme = null;
      weatherService.weatherRM.state = const Weather(
        condition: WeatherCondition.cloudy,
        location: 'London',
        temperature: 2,
      );
      await tester.pump();
      expect(testColorTheme, null);
    },
  );
}

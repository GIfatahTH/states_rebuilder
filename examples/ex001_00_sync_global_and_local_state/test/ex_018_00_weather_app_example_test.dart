import 'package:ex001_00_sync_global_and_local_state/ex_018_00_weather_app_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFakeWeatherRepository extends Mock implements FakeWeatherRepository {}

void main() {
  final fakeRepository = MockFakeWeatherRepository();
  setUp(() {
    weatherRepository.injectMock(() => fakeRepository);
  });

  testWidgets(
    'Fetch city without error',
    (tester) async {
      when(() => fakeRepository.fetchWeather('City')).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => Weather(cityName: 'City', temperatureCelsius: 10),
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.enterText(find.byType(TextField), 'City');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('City'), findsOneWidget);
      expect(find.text('10.0 °C'), findsOneWidget);
    },
  );

  testWidgets(
    'Fetch city with error',
    (tester) async {
      when(() => fakeRepository.fetchWeather('City')).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => throw NetworkException('Failure'),
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.enterText(find.byType(TextField), 'City');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failure'), findsOneWidget);
      expect(find.text('City'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets(
    'Fetch city and navigate to detailed',
    (tester) async {
      when(() => fakeRepository.fetchWeather('City')).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => Weather(cityName: 'City', temperatureCelsius: 10),
        ),
      );
      when(() => fakeRepository.fetchDetailedWeather('City')).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => Weather(
            cityName: 'City',
            temperatureCelsius: 10,
            temperatureFahrenheit: 100,
          ),
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.enterText(find.byType(TextField), 'City');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('City'), findsOneWidget);
      expect(find.text('10.0 °C'), findsOneWidget);
      //
      await tester.tap(find.text('See Details'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(WeatherDetailPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('10.0 °C'), findsOneWidget);
      expect(find.text('100.0 °F'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('100.0 °F'), findsOneWidget);
    },
  );
}

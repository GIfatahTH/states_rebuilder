import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* This example shows how to use state interceptor
*
* In the demo, depending on the weather conditions, we want to change the theme. 
* We will use the state interceptor to optimize the theme modification call and 
* limit it only when the weather conditions are changed.
*
* The example is inspired from weather example of Flutter Bloc library
*/

enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown,
}

const defaultColor = Color(0xFF2196F3);

// Set primary color theme depending on the weather condition
Color setColor(WeatherCondition condition) {
  switch (condition) {
    case WeatherCondition.clear:
      return Colors.orangeAccent;
    case WeatherCondition.snowy:
      return Colors.lightBlueAccent;
    case WeatherCondition.cloudy:
      return Colors.blueGrey;
    case WeatherCondition.rainy:
      return Colors.indigoAccent;
    case WeatherCondition.unknown:
    default:
      return defaultColor;
  }
}

// Weather data class
class Weather {
  final WeatherCondition condition;
  final String location;
  final double temperature;
  final Color themeColor;
  const Weather({
    required this.condition,
    required this.location,
    required this.temperature,
    this.themeColor = defaultColor,
  });

  Weather copyWith({
    WeatherCondition? condition,
    String? location,
    double? temperature,
    Color? themeColor,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}

@immutable
class WeatherService {
  final weatherRM = RM.inject<Weather?>(
    () => null,
    // stateInterceptor is called after new state calculation and just before
    // state mutation. It exposes the current and the next snapState
    stateInterceptor: (currentSnap, nextSnap) {
      if (currentSnap.state?.condition != nextSnap.state?.condition) {
        // notify theme to change only if the weather condition changes
        theme.notify();
        // Change the weather state to hold the right theme color
        return nextSnap.copyWith(
          data: nextSnap.state!.copyWith(
            themeColor: setColor(nextSnap.state!.condition),
          ),
        );
      }
      return null;
    },
  );
  Weather? get weather => weatherRM.state;
  Color get themeColor => weather?.themeColor ?? defaultColor;
  //

  void getWeather() {
    // simple sync weather search method
    final result = dummyWeathers[Random().nextInt(dummyWeathers.length)];
    weatherRM.state = weatherRM.state?.copyWith(
          location: result.location,
          condition: result.condition,
          temperature: result.temperature,
        ) ??
        result;
  }
}

final weatherService = WeatherService();
// Inject the theme
final theme = RM.inject(() => ThemeData.light());

void main() {
  runApp(const MyApp());
}

// Used to test rebuild
Color? testColorTheme;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    // Use onBuilder to listen to theme only
    return OnBuilder(
      listenTo: theme,
      builder: () {
        // If condition does not change, this build should not rebuild
        testColorTheme = weatherService.themeColor;
        return MaterialApp(
          title: 'Flutter Demo',
          theme: theme.state.copyWith(
            primaryColor: weatherService.themeColor,
          ),
          home: const WeatherView(),
        );
      },
    );
  }
}

class WeatherView extends ReactiveStatelessWidget {
  const WeatherView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather of today'),
      ),
      body: Center(
        child: weatherService.weather == null
            ? const Text('Fetch for the weather of tody')
            : Container(
                color: Theme.of(context).primaryColor,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weatherService.weather!.location,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    Text(
                      weatherService.weather!.condition.name,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    Text(
                      weatherService.weather!.temperature.toString(),
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: weatherService.getWeather,
        child: const Icon(Icons.search),
      ),
    );
  }
}

final dummyWeathers = [
  const Weather(
    condition: WeatherCondition.clear,
    location: 'Touggourt',
    temperature: 28,
  ),
  const Weather(
    condition: WeatherCondition.clear,
    location: 'Mecca',
    temperature: 32,
  ),
  const Weather(
    condition: WeatherCondition.cloudy,
    location: 'London',
    temperature: 02,
  ),
  const Weather(
    condition: WeatherCondition.cloudy,
    location: 'Madrid',
    temperature: 06,
  ),
  const Weather(
    condition: WeatherCondition.rainy,
    location: 'Istanbul',
    temperature: 11,
  ),
  const Weather(
    condition: WeatherCondition.rainy,
    location: 'Rabat',
    temperature: 13,
  ),
  const Weather(
    condition: WeatherCondition.snowy,
    location: 'Oslo',
    temperature: -16,
  ),
  const Weather(
    condition: WeatherCondition.snowy,
    location: 'Chicago',
    temperature: -1,
  ),
];

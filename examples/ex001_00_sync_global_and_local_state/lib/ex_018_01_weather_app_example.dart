import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// This is a rewrite of the weather app from ResoCoder tutorial using the new
// states_rebuilder_api.

// In this example we will use the predefined states_rebuilder flags
// Models
class Weather {
  final String cityName;
  final double temperatureCelsius;
  final double? temperatureFahrenheit;

  Weather({
    required this.cityName,
    required this.temperatureCelsius,
    this.temperatureFahrenheit,
  });
}

// Repositories interfaces
abstract class WeatherRepository {
  Future<Weather> fetchWeather(String cityName);
  Future<Weather> fetchDetailedWeather(String cityName);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

@immutable
class WeatherService {
  final _weatherRM = RM.inject<Weather?>(
    () => null,
    sideEffects: SideEffects.onError(
      (err, refresh) {
        ScaffoldMessenger.of(RM.context!)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(err),
            ),
          );
      },
    ),
  );

  Weather get wether => _weatherRM.state!;
  late final whenWether = _weatherRM.onAll;
  //
  late final _weatherDetailedRM = RM.inject<Weather?>(
    () => null,
    sideEffects: SideEffects(
      initState: () => fetchDetailedWeather(wether.cityName),
    ),
  );
  Weather get wetherDetailed => _weatherDetailedRM.state!;
  late final whenWetherDetailed = _weatherDetailedRM.onOrElse;

  //
  void fetchWeather(String cityName) async {
    try {
      _weatherRM.setToIsWaiting();
      final weather = await weatherRepository.state.fetchWeather(cityName);
      _weatherRM.setToHasData(weather);
    } catch (e) {
      if (e is NetworkException) {
        _weatherRM.setToHasError(e.message);
      } else {
        rethrow;
      }
    }
  }

  void fetchDetailedWeather(String cityName) async {
    try {
      _weatherDetailedRM.setToIsWaiting();
      final weather =
          await weatherRepository.state.fetchDetailedWeather(cityName);
      _weatherDetailedRM.setToHasData(weather);
    } catch (e) {
      if (e is NetworkException) {
        _weatherDetailedRM.setToHasError(e);
      } else {
        rethrow;
      }
    }
  }
}

final weatherRepository = RM.inject(() => FakeWeatherRepository());
final weatherService = WeatherService();
// Notice the code repetition in fetchWeather and fetchDetailedWeather methods.
// Using async state mutation will remove all the repetition and make the code
// cleaner

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherSearchPage(),
    );
  }
}

class WeatherSearchPage extends ReactiveStatelessWidget {
  const WeatherSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Search"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: weatherService.whenWether(
          onIdle: () => buildInitialInput(),
          onWaiting: () => const LoadingWidget(),
          onError: (_, __) => buildInitialInput(),
          onData: (data) => buildColumnWithData(context),
        ),
      ),
    );
  }

  Widget buildInitialInput() {
    return const Center(
      child: CityInputField(),
    );
  }

  Column buildColumnWithData(BuildContext context) {
    final Weather weather = weatherService.wether;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          weather.cityName,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          // Display the temperature with 1 decimal place
          "${weather.temperatureCelsius.toStringAsFixed(1)} °C",
          style: const TextStyle(fontSize: 80),
        ),
        ElevatedButton(
          child: const Text('See Details'),
          style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue[100],
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const WeatherDetailPage(),
            ));
          },
        ),
        const CityInputField(),
      ],
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class CityInputField extends StatelessWidget {
  const CityInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        onSubmitted: (value) => weatherService.fetchWeather(value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Enter a city",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class WeatherDetailPage extends StatelessWidget {
  const WeatherDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Weather weather = weatherService.wether;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Detail"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              weather.cityName,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              // Display the Celsius temperature with 1 decimal place
              "${weather.temperatureCelsius.toStringAsFixed(1)} °C",
              style: const TextStyle(fontSize: 80),
            ),
            OnReactive(
              () => weatherService.whenWetherDetailed(
                onWaiting: () => const LoadingWidget(),
                orElse: (data) => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "${data!.temperatureFahrenheit?.toStringAsFixed(1)} °F",
                      style: const TextStyle(fontSize: 80),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Repositories implementation
class FakeWeatherRepository implements WeatherRepository {
  double? cachedTempCelsius;

  @override
  Future<Weather> fetchWeather(String cityName) {
    // Simulate network delay
    return Future.delayed(
      const Duration(seconds: 1),
      () {
        final random = Random();

        // Simulate some network error
        if (random.nextBool()) {
          throw NetworkException('Network failure');
        }

        // Since we're inside a fake repository, we need to cache the temperature
        // in order to have the same one returned in for the detailed weather
        cachedTempCelsius = 20 + random.nextInt(15) + random.nextDouble();

        // Return "fetched" weather
        return Weather(
          cityName: cityName,
          // Temperature between 20 and 35.99
          temperatureCelsius: cachedTempCelsius!,
        );
      },
    );
  }

  @override
  Future<Weather> fetchDetailedWeather(String cityName) {
    // Simulate network delay
    return Future.delayed(
      const Duration(seconds: 1),
      () {
        return Weather(
          cityName: cityName,
          temperatureCelsius: cachedTempCelsius!,
          temperatureFahrenheit: cachedTempCelsius! * 1.8 + 32,
        );
      },
    );
  }
}

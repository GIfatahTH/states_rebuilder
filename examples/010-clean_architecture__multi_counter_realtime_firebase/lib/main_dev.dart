import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'my_app.dart';

//to run the app use : flutter run  -t lib/main_dev.dart
void main() {
  Injector.env = Flavor.Dev;
  runApp(new MyApp());
}

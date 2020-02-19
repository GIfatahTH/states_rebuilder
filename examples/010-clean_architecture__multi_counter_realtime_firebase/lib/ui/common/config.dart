import 'package:flutter/material.dart';

abstract class IConfig {
  MaterialColor get primarySwatch;
  String get appTitle;
}

class ProdConfig extends IConfig {
  @override
  String get appTitle => 'Production flavor';

  @override
  MaterialColor get primarySwatch => Colors.blue;
}

class DevConfig extends IConfig {
  @override
  String get appTitle => 'Development flavor';

  @override
  MaterialColor get primarySwatch => Colors.orange;
}

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final i18n = RM.injectI18N({
  Locale('en'): () => EN(),
  Locale('es'): () => ES(),
  Locale('ar'): () => AR(),
  Locale('de'): () => DE(),
});

abstract class I18n {
  final String languageName;
  I18n(this.languageName);
  final helloWorldExample = 'Hello world Example';
  final startStreaming = 'Start Streaming';
  final enterYourName = 'Enter your name';
}

class EN extends I18n {
  EN() : super('English');
}

class ES implements I18n {
  @override
  String get languageName => 'Spanish';

  final helloWorldExample = 'Hola mundo Ejemplo';
  final startStreaming = 'Comenzar a transmitir';
  final enterYourName = 'Introduzca su nombre';
}

class AR implements I18n {
  @override
  String get languageName => 'Arabic';

  final helloWorldExample = 'مثال مرحبا بالعالم';
  final startStreaming = 'إبدا التدفق';
  final enterYourName = 'إدخل إسمك';
}

class DE implements I18n {
  @override
  String get languageName => 'German';

  final helloWorldExample = 'Hallo Welt Beispiel';
  final startStreaming = 'Starten Sie das Streaming';
  final enterYourName = 'Gib deinen Namen ein';
}

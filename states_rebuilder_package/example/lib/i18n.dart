// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final i18n = RM.injectI18N({
  const Locale('en'): () => EN(),
  const Locale('es'): () => ES(),
  const Locale('ar'): () => AR(),
  const Locale('de'): () => DE(),
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

  @override
  final helloWorldExample = 'Hola mundo Ejemplo';
  @override
  final startStreaming = 'Comenzar a transmitir';
  @override
  final enterYourName = 'Introduzca su nombre';
}

class AR implements I18n {
  @override
  String get languageName => 'Arabic';

  @override
  final helloWorldExample = 'مثال مرحبا بالعالم';
  @override
  final startStreaming = 'إبدا التدفق';
  @override
  final enterYourName = 'إدخل إسمك';
}

class DE implements I18n {
  @override
  String get languageName => 'German';

  @override
  final helloWorldExample = 'Hallo Welt Beispiel';
  @override
  final startStreaming = 'Starten Sie das Streaming';
  @override
  final enterYourName = 'Gib deinen Namen ein';
}

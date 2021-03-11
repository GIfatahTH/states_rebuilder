import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'translations/ar.dart';
import 'translations/en_us.dart';

final i18n = RM.injectI18N(
  {
    Locale('en', ''): () => EN(),
    Locale('ar', ''): () => AR(),
  },
  persistKey: '__locale__',
);

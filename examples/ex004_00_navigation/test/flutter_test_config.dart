// Source - https://stackoverflow.com/a/73048760
// Posted by yshean
// Retrieved 2026-08-16, License - CC BY-SA 4.0

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'local_file_comparator_with_threshold.dart';

/// Customise your threshold here
/// For example, the error threshold here is 0.5%
/// Golden tests will pass if the pixel difference is equal to or below 0.5%
const _kGoldenTestsThreshold = 0.5 / 100;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  if (goldenFileComparator is LocalFileComparator) {
    final testUrl = (goldenFileComparator as LocalFileComparator).basedir;

    goldenFileComparator = LocalFileComparatorWithThreshold(
      // flutter_test's LocalFileComparator expects the test's URI to be passed
      // as an argument, but it only uses it to parse the baseDir in order to
      // obtain the directory where the golden tests will be placed.
      // As such, we use the default `testUrl`, which is only the `baseDir` and
      // append a generically named `test.dart` so that the `baseDir` is
      // properly extracted.
      Uri.parse('$testUrl/test.dart'),
      _kGoldenTestsThreshold,
    );
  } else {
    throw Exception(
      'Expected `goldenFileComparator` to be of type `LocalFileComparator`, '
      'but it is of type `${goldenFileComparator.runtimeType}`',
    );
  }

  await testMain();
}

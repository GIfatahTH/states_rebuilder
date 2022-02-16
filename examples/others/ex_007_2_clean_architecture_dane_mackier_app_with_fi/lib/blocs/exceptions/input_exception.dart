class NotNumberException implements Exception {
  final message = 'The entered value is not a number';
}

class NotInRangeException implements Exception {
  final message = 'The entered value is not between 1 and 10';
}

class NullNumberException implements Exception {
  final message = 'The entered value is null';
}

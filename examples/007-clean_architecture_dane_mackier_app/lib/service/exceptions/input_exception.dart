class NotNumberException extends Error {
  final message = 'The entered value is not a number';
}

class NotInRangeException extends Error {
  final message = 'Tne entered value is not between 1 and 10';
}

class PersistanceException implements Exception {
  final String message;
  PersistanceException(this.message);
  @override
  String toString() {
    return message.toString();
  }
}

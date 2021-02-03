import 'dart:math';

class NameRepository {
  Future<String> getNameInfo(String name) async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextInt(10) > 6) {
      throw Exception('Server Error');
    }
    return 'This is the info of $name';
  }
}

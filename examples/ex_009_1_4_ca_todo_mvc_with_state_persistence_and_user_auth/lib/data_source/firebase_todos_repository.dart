import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';

import 'constants.dart';

class FireBaseTodosRepository implements IPersistStore {
  final String authToken;

  FireBaseTodosRepository({
    @required this.authToken,
  });

  @override
  Future<void> init() async {}

  @override
  Object read(String key) async {
    final response = await http.get('$baseUrl/$key.json?auth=$authToken');
    if (response.statusCode > 400) {
      throw Exception();
    }
    return response.body;
  }

  @override
  Future<void> write<T>(String key, T value) async {
    final response =
        await http.put('$baseUrl/$key.json?auth=$authToken', body: value);
    if (response.statusCode >= 400) {
      throw Exception();
    }
  }

  @override
  Future<void> delete(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll() {
    throw UnimplementedError();
  }
}

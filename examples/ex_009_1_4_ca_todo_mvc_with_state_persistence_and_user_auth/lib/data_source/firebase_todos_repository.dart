import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';

import 'my_project_data.dart' as myProjectData; //TODO Delete this.

//1. create firebase project.
//2. create a realtime database and start in test mode.
//3. notice the generated url which we will use. If your project name is YOUR_PROJECT_NAME the the generated url is https://YOUR_PROJECT_NAME.firebaseio.com/. This will be your `baseUrl` const.
const baseUrl = myProjectData.baseUrl; //TODO Use yours.

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

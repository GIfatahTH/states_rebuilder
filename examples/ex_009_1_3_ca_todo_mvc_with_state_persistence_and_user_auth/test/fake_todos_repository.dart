// import 'package:flutter/foundation.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';

// class FireBaseTodosRepository implements PersistStoreMock {
//   final String userId;
//   final String authToken;

//   FireBaseTodosRepository({
//     @required this.userId,
//     @required this.authToken,
//   });

//   @override
//   Future<void> init() async {}

//   @override
//   Object read(String key) async {
//     final response =
//         await http.get('$baseUrl/$key/$userId.json?auth=$authToken');
//     if (response.statusCode > 400) {
//       throw Exception();
//     }
//     return response.body;
//   }

//   @override
//   Future<void> write<T>(String key, T value) async {
//     final response = await http
//         .put('$baseUrl/$key/$userId.json?auth=$authToken', body: value);
//     if (response.statusCode >= 400) {
//       throw Exception();
//     }/
//   }

// @override/
//   Future<void> delete(String key) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> deleteAll() {
//     throw UnimplementedError();
//   }
// }

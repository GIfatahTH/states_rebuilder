// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';

// import 'service/exceptions/persistance_exception.dart';

// class SharedPreferencesImp implements IPersistStore {
//   SharedPreferences _sharedPreferences;

//   @override
//   Future<void> init() async {
//     _sharedPreferences = await SharedPreferences.getInstance();
//   }

//   @override
//   Object read(String key) {
//     try {
//       return _sharedPreferences.getString(key);
//     } catch (e) {
//       throw PersistanceException('There is a problem in loading todos: $e');
//     }
//   }

//   @override
//   Future<void> write<T>(String key, T value) async {
//     try {
//       // await Future.delayed(Duration(seconds: 3));
//       // throw Exception('Error');
//       return _sharedPreferences.setString(key, value as String);
//     } catch (e) {
//       throw PersistanceException('There is a problem in saving todos: $e');
//     }
//   }

//   @override
//   Future<void> delete(String key) async {
//     return _sharedPreferences.remove(key);
//   }

//   @override
//   Future<void> deleteAll() {
//     return _sharedPreferences.clear();
//   }
// }

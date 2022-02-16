import 'package:ex_006_crud_app/number.dart';
import 'package:ex_006_crud_app/numbers_repository.dart';

class FakeNumbersRepository implements NumbersRepository {
  late Map<String, List<Number>> _numbersStore = {};
  dynamic exception;
  late int idToCreate;
  @override
  Future<void> init() async {
    await Future.delayed(Duration(seconds: 1));
    _numbersStore = {
      '1': [Number(id: '1', number: 0), Number(id: '2', number: 11)]
    };
  }

  @override
  Future<Number> create(Number number, NumberParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    final userNumbers = _numbersStore[param!.userId] ?? [];
    final numberToAdd = Number(
      id: idToCreate.toString(),
      number: number.number,
    );
    _numbersStore[param.userId] = [...userNumbers, numberToAdd];
    print(_numbersStore);
    return numberToAdd;
  }

  @override
  Future<List<Number>> read(NumberParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    final userNumbers = _numbersStore[param!.userId] ?? [];

    if (param.numType == NumType.even) {
      return userNumbers.where((e) => e.number % 2 == 0).toList();
    }
    if (param.numType == NumType.odd) {
      return userNumbers.where((e) => e.number % 2 == 1).toList();
    }
    return [...userNumbers];
  }

  @override
  Future update(List<Number> numbers, NumberParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    final userNumbers = _numbersStore[param!.userId] ?? [];
    for (var number in numbers) {
      final index = userNumbers.indexWhere((e) => e.id == number.id);
      if (index < 0) {
        throw Exception('Can not update non existing number');
      }
      userNumbers[index] = number;
    }
    _numbersStore[param.userId] = [...userNumbers];
  }

  @override
  Future delete(List<Number> numbers, NumberParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    final userNumbers = _numbersStore[param!.userId] ?? [];
    for (var number in numbers) {
      final isRemoved = userNumbers.remove(number);
      if (!isRemoved) {
        throw Exception('Can not delete non exisiting number');
      }
    }
    _numbersStore[param.userId] = [...userNumbers];
    print(_numbersStore);
  }

  Future<int> count(NumberParam param) async {
    final userNumbers = _numbersStore[param.userId] ?? [];

    if (param.numType == NumType.even) {
      return userNumbers.where((e) => e.number % 2 == 0).length;
    }
    if (param.numType == NumType.odd) {
      return userNumbers.where((e) => e.number % 2 == 1).length;
    }
    return userNumbers.length;
  }

  @override
  void dispose() {}
}

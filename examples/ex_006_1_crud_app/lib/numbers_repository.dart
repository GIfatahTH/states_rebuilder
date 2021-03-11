import 'dart:math';

import 'package:states_rebuilder/states_rebuilder.dart';

import 'number.dart';

class NumbersRepository implements ICRUD<Number, NumberParam> {
  late Map<String, List<Number>> _numbersStore;

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
    if (Random().nextBool()) {
      throw Exception('Error');
    }
    final userNumbers = _numbersStore[param!.userId] ?? [];
    _numbersStore[param.userId] = [...userNumbers, number];
    print(_numbersStore);
    return number;
  }

  @override
  Future<List<Number>> read(NumberParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('Error');
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
    if (Random().nextBool()) {
      throw Exception('Error');
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
    print(_numbersStore);
  }

  @override
  Future delete(List<Number> numbers, NumberParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('Error');
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

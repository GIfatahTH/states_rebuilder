import 'package:flutter/foundation.dart';

class TodosStats {
  final int numCompleted;
  final int numActive;
  final bool allComplete;

  TodosStats({
    @required this.numCompleted,
    @required this.numActive,
  }) : allComplete = numActive == 0;

  @override
  String toString() =>
      'TodosStats(numCompleted: $numCompleted, numActive: $numActive)';
}

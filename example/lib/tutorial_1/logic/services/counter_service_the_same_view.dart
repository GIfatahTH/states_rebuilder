import 'package:states_rebuilder/states_rebuilder.dart';

class CounterServiceSameView extends ObservableService {
  int counter = 0;

  increment() {
    counter++;
    rebuildStates();
  }
}

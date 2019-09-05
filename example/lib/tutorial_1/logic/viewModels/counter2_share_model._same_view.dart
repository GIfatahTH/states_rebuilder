import 'package:states_rebuilder/states_rebuilder.dart';
import '../services/counter_service_the_same_view.dart';

class Counter2ShareModelSameView extends StatesRebuilder {
  final counterService = Injector.get<CounterServiceSameView>();

  Counter2ShareModelSameView() {
    counterService.addObserver(this);
  }

  int get counter => counterService.counter;
  increment() {
    counterService.increment();
  }
}


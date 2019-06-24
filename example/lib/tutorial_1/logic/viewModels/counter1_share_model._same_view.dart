import 'package:states_rebuilder/states_rebuilder.dart';
import '../services/counter_service_the_same_view.dart';

class Counter1ShareModelSameView extends StatesRebuilder {
  final counterService = Injector.get<CounterServiceSameView>();

  int get counter => counterService.counter;
  increment() {
    counterService.increment();
  }
}

import '../domain/entities/counter.dart';
import 'interfaces/i_counter_repository.dart';

class CountersService {
  final ICounterRepository _counterRepository;

  CountersService(this._counterRepository);

  void createCounter() async {
    await _counterRepository.createCounter();
  }

  void increment(Counter counter) async {
    counter.value++;
    await _counterRepository.setCounter(counter);
  }

  void decrement(Counter counter) async {
    counter.value--;
    await _counterRepository.setCounter(counter);
  }

  void delete(Counter counter) async {
    await _counterRepository.deleteCounter(counter);
  }

  Stream<List<Counter>> countersStream() {
    return _counterRepository.countersStream();
  }
}

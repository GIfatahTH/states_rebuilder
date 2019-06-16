class CounterService {
  int _counter = 0;
  int get counter => _counter;

  increment() {
    _counter++;
  }
}

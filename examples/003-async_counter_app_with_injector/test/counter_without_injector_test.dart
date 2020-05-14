// counter_without_injector.dart can not be tested
// because MyApp class depends directly on CounterStore
// so CounterStore can not be mocked and its behavior
// can not be expected.

//One obvious solution is to inject the CounterStore dependency through the constructor.
// and this is what we do not want to do now.

//We want to use Injector.
// void main() {}

import 'package:firebase_database/firebase_database.dart';

import '../domain/entities/counter.dart';
import '../service/interfaces/i_counter_repository.dart';

class CounterFirebaseRepository implements ICounterRepository {
  //Get a DatabaseReference for the counters path
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference().child('counters');

  @override
  Stream<List<Counter>> countersStream() {
    Stream<List<Counter>> stream;

    //Map the onValue stream to return a stream of list of counters
    stream = databaseReference.onValue.map((event) {
      Map<dynamic, dynamic> values = event.snapshot.value;
      if (values == null) {
        return [];
      }
      Iterable<String> keys = values.keys.cast<String>();

      List<Counter> counters = keys
          .map((key) => Counter(id: int.parse(key), value: values[key]))
          .toList();

      return counters ?? [];
    });

    return stream;
  }

  @override
  Future<void> createCounter() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    Counter counter = Counter(id: now, value: 0);
    await setCounter(counter);
  }

  @override
  Future<void> setCounter(Counter counter) async {
    await databaseReference.child('${counter.id}').set(counter.value);
  }

  @override
  Future<void> deleteCounter(Counter counter) async {
    await databaseReference.child('${counter.id}').remove();
  }
}

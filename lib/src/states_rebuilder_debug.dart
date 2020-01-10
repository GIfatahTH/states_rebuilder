import 'package:flutter/widgets.dart';

import 'injector.dart';
import 'states_rebuilder.dart';

class StatesRebuilderDebug {
  //Print registered models in the service locator
  static printInjectedModel() {
    print('Number of registered models : ' +
        InjectorState.allRegisteredModelInApp.length.toString());

    String text = '{\n';
    InjectorState.allRegisteredModelInApp.forEach((k, list) {
      text += k +
          ' : ' +
          list
              .map((inject) => '${inject.runtimeType}(${inject.hashCode})')
              .toList()
              .toString() +
          '\n';
    });
    debugPrint(text + ' }');
  }

  ///Print subscribed observers of an observable object
  static printObservers(StatesRebuilder observable) {
    print('Number of observers subscribed to ${observable.runtimeType} is: ' +
        observable.observers().length.toString());

    String text = '{\n';
    observable.observers().forEach((k, list) {
      text += k +
          ' : ' +
          list
              .map(
                  (observer) => '${observer.runtimeType}(${observer.hashCode})')
              .toList()
              .toString() +
          '\n';
    });
    debugPrint(text + ' }');
  }
}

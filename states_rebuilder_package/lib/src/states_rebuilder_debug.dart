import 'package:flutter/widgets.dart';
import 'injector.dart';

import 'states_rebuilder.dart';

class StatesRebuilderDebug {
  //Print registered models in the service locator
  static String printInjectedModel() {
    String text = 'Number of registered models : ' +
        InjectorState.allRegisteredModelInApp.length.toString();

    text += '\n{\n';
    InjectorState.allRegisteredModelInApp.forEach((k, list) {
      text += k +
          ' : ' +
          list
              .map((inject) => '${inject.runtimeType}(${inject.hashCode})')
              .toList()
              .toString() +
          '\n';
    });
    text += '}';
    debugPrint(text);
    return text;
  }

  ///Print subscribed observers of an observable object
  static String printObservers(StatesRebuilder observable) {
    String text =
        'Number of observers subscribed to ${observable.runtimeType} is: ' +
            observable.observers().length.toString();

    text += '\n{\n';
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

    text += '}';

    debugPrint(text);
    return text;
  }
}

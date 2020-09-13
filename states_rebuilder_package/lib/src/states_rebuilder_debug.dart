import 'package:flutter/widgets.dart';

import 'injector.dart';
import 'states_rebuilder.dart';

///States_Rebuilder logger
class StatesRebuilerLogger {
  ///Set to true to avoid printing in test mode
  static bool isTestMode = false;

  ///The current printed message
  static String message;

  ///Console log the error
  static void log(String m, [dynamic e, StackTrace s]) {
    String errorMessage;
    try {
      errorMessage = e?.message as String;
    } catch (e) {
      errorMessage = '$e';
    }
    errorMessage ??= '';

    message = '[states_rebuilder]: $m: $errorMessage';
    if (!isTestMode) print(message);
  }
}

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

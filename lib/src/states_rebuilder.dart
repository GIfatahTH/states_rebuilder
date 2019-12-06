import 'dart:collection';

import 'package:flutter/material.dart';

///[StatesRebuilder] use the observer pattern.
///
///Observer classes should implement [ObserverOfStatesRebuilder]
abstract class ObserverOfStatesRebuilder {
  bool update([void Function(BuildContext) onSetState]);
}

///[StatesRebuilder] use the observer pattern.
///
///Observable class should implement [ObserverOfStatesRebuilder]
abstract class Subject {
  ///Notify observers
  void rebuildStates([List<dynamic> tags]);

  void addObserver({
    @required ObserverOfStatesRebuilder observer,
    @required String tag,
  });

  void removeObserver({
    @required ObserverOfStatesRebuilder observer,
    @required String tag,
  });
}

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder implements Subject {
  ///key holds the observer tags and the value holds the observers
  ///_observers = {"tag" : [ observer]}
  ///Observers are  automatically add and removed by [StateBuilder] in the [State.initState] and [State.dispose]  methods.
  final LinkedHashMap<String, List<ObserverOfStatesRebuilder>> _observers =
      LinkedHashMap<String, List<ObserverOfStatesRebuilder>>();

  ///Holds user defined void callback to be executed when notification is emitted.
  final List<VoidCallback> _customObservers = <VoidCallback>[];

  ///Folds user defined void callback to be executed after removing all observers.
  final List<VoidCallback> _cleanerVoidCallBackList = <VoidCallback>[];

  ///Define a function to be called each time a tag is removed
  Function(String) statesRebuilderCleaner;

  /// observers getter
  Map<String, List<ObserverOfStatesRebuilder>> observers() => _observers;

  ///use [hasObservers] instead
  @deprecated
  bool get hasState => _observers.isNotEmpty;

  ///Check whether the model has observing states
  bool get hasObservers => _observers.isNotEmpty;

  ///Check whether the model has user defined observing states
  bool get hasCustomObservers => _customObservers.isNotEmpty;

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  ///
  /// It will notify observers with [tags] and executed [onSetState] after notification is sent.
  @override
  void rebuildStates(
      [List<dynamic> tags, void Function(BuildContext) onSetState]) {
    assert(() {
      if (!hasObservers && _customObservers.isEmpty) {
        throw Exception('ERR(rebuildStates)01: No observer is registered yet.\n'
            'You have to register at least one observer using the `StateBuilder` or StateWithMixinBuilder` widgets.\n'
            'If you are sure you have registered at least one observer and you still see this error, please report an issue in the repository.\n');
      }
      return true;
    }());

    //used to ensure that [onSetState] is executed only one time.
    bool _onRebuildCallBackIsCalled = false;

    if (tags == null) {
      final Iterable<String> _keys = _observers.keys.toList()?.reversed;

      for (final String key in _keys) {
        final List<ObserverOfStatesRebuilder> observerList = _observers[key];
        if (observerList != null) {
          for (ObserverOfStatesRebuilder observer in observerList) {
            if (onSetState != null && _onRebuildCallBackIsCalled == false) {
              _onRebuildCallBackIsCalled = observer?.update(onSetState) == true;
            } else {
              observer?.update();
            }
          }
        }
      }

      for (void Function() customObserver in _customObservers) {
        customObserver();
      }
      return;
    }

    for (final dynamic tag in tags) {
      String _tag;

      if (tag is BuildContext) {
        _tag = '#@deFau_Lt${tag.hashCode}TaG30';
      } else {
        _tag = tag.toString();
      }

      final List<ObserverOfStatesRebuilder> observerList = _observers['$_tag'];
      if (observerList != null) {
        for (ObserverOfStatesRebuilder observer in observerList) {
          if (onSetState != null && _onRebuildCallBackIsCalled == false) {
            _onRebuildCallBackIsCalled = observer?.update(onSetState);
          } else {
            observer?.update();
          }
        }
      }
    }
  }

  /// Method to add observer
  @override
  void addObserver({
    @required String tag,
    @required ObserverOfStatesRebuilder observer,
  }) {
    if (tag == null || observer == null) {
      return;
    }
    //observers are add at the beginning of the list.
    _observers[tag] = _observers[tag] == null
        ? <ObserverOfStatesRebuilder>[observer]
        : <ObserverOfStatesRebuilder>[observer, ..._observers[tag]];
  }

  ///Method to remove observer
  @override
  void removeObserver({
    @required String tag,
    @required ObserverOfStatesRebuilder observer,
  }) {
    if (tag != null) {
      assert(() {
        if (_observers[tag] == null) {
          final Iterable<String> _keys = _observers.keys;
          throw Exception(
              'ERR(removeFromObservers)01: The tag: $tag is not registered in this VM observers.\n'
              'If you see this error, please report an issue in the repository.\n'
              'The registered tags are : $_keys');
        }
        return true;
      }());

      _observers[tag].remove(observer);
      if (_observers[tag].isEmpty) {
        if (statesRebuilderCleaner != null) {
          statesRebuilderCleaner(tag);
        }
        _observers.remove(tag);

        if (_observers.isEmpty) {
          if (statesRebuilderCleaner != null) {
            statesRebuilderCleaner(null);
          }
          statesRebuilderCleaner = null;
          //[_cleanerVoidCallBackList] void call backs are executed after both [_observers] and [__customObservers] are empty
          if (_customObservers.isEmpty) {
            for (final void Function() voidCallBack
                in _cleanerVoidCallBackList) {
              if (voidCallBack != null) {
                voidCallBack();
              }
            }
            _cleanerVoidCallBackList.clear();
          }
        }
      }
    } else {
      for (final void Function() voidCallBack in _cleanerVoidCallBackList) {
        if (voidCallBack != null) {
          voidCallBack();
        }
      }
      _cleanerVoidCallBackList.clear();
    }
  }

  ///Add a callback to be executed when all listeners are removed
  void cleaner(VoidCallback voidCallback) {
    _cleanerVoidCallBackList.add(voidCallback);
  }

  ///Add a custom void callback to be executed when notification is sent.
  void addCustomObserver(void Function() fn) {
    _customObservers.add(fn);
  }
}

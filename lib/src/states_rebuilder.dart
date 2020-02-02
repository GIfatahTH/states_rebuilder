import 'dart:collection';

import 'package:flutter/widgets.dart';

///[StatesRebuilder] use the observer pattern.
///
///Observer classes should implement [ObserverOfStatesRebuilder]
abstract class ObserverOfStatesRebuilder {
  ///Method to executed when observer is notified.
  bool update([void Function(BuildContext) onSetState]);
}

///[StatesRebuilder] use the observer pattern.
///
///Observable class should implement [Subject]
abstract class Subject {
  ///Notify observers
  void rebuildStates(
      [List<dynamic> tags, void Function(BuildContext) onSetState]);

  ///Add Observer
  void addObserver({
    @required ObserverOfStatesRebuilder observer,
    @required String tag,
  });

  ///Remove observer
  void removeObserver({
    @required ObserverOfStatesRebuilder observer,
    @required String tag,
  });
}

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder implements Subject {
  ///key holds the observer tags and the value holds the observers
  ///_observers = {"tag" : [observer1, observer2, ...]}
  ///Observers are  automatically add and removed by [StateBuilder] in the [State.initState] and [State.dispose]  methods.
  final LinkedHashMap<String, List<ObserverOfStatesRebuilder>> _observersMap =
      LinkedHashMap<String, List<ObserverOfStatesRebuilder>>();

  /// observers getter
  Map<String, List<ObserverOfStatesRebuilder>> observers() => _observersMap;
  bool get hasObservers => _observersMap.isNotEmpty;

  ///Holds user defined void callback to be executed after removing all observers.
  final List<VoidCallback> _statesRebuilderCleaner = <VoidCallback>[];

  @override
  @mustCallSuper
  void addObserver({ObserverOfStatesRebuilder observer, String tag}) {
    assert(observer != null);
    assert(tag != null);
    Map<String, List<ObserverOfStatesRebuilder>> observersTemp = {};
    observersTemp.addAll(_observersMap);
    _observersMap.clear();
    //observers are add at the beginning of the list.
    if (observersTemp[tag] == null) {
      _observersMap[tag] = <ObserverOfStatesRebuilder>[observer];
      _observersMap.addAll(observersTemp);
    } else {
      observersTemp[tag] = [observer, ...observersTemp[tag]];
      _observersMap.addAll(observersTemp);
    }
  }

  @override
  @mustCallSuper
  void removeObserver({ObserverOfStatesRebuilder observer, String tag}) {
    assert(
      () {
        if (_observersMap[tag] == null) {
          throw Exception(
            '''

| ***Non registered Tag***
| The tag: [$tag] is not registered in this [$runtimeType] observers.
| Tags are automatically registered by states_rebuilder.
| If you see this error, this means that something wrong happens.
| Please report an issue.
| 
| The registered tags are : ${_observersMap.keys}
       ''',
          );
        }
        return true;
      }(),
    );

    _observersMap[tag].remove(observer);
    if (_observersMap[tag].isEmpty) {
      _observersMap.remove(tag);
      if (_observersMap.isEmpty) {
        //Al observers are remove, it is time to execute custom cleaning
        for (final void Function() voidCallBack in _statesRebuilderCleaner) {
          if (voidCallBack != null) {
            voidCallBack();
          }
        }
        _statesRebuilderCleaner.clear();
      }
    }
  }

  /// You call [rebuildState] inside any of your logic classes that extends [StatesRebuilder].
  ///
  /// It will notify observers with [tags] and executed [onSetState] after notification is sent.
  @override
  void rebuildStates([List tags, void Function(BuildContext) onSetState]) {
    assert(() {
      if (!hasObservers) {
        throw Exception(
          '''

***No observer is subscribed yet***
| There is no observer subscribed to this observable $runtimeType model.
| To subscribe a widget you use:
| 1- StateRebuilder for an already defined:
|   ex:
|   StatesRebuilder(
|     models: [${runtimeType}instance],
|     builder : ....
|   )
| 2- Injector.get<$runtimeType>(context : context). for explicit reactivity.
| 3- Injector.getAsReactive<$runtimeType>(context : context). for implicit reactivity.
| 4- StateRebuilder for new reactive environment:
|   ex:
|   StatesRebuilder<$runtimeType>(
|     builder : ....
|   )
| 5 - StatesWithMixinBuilder. similar to StateBuilder.
| 
| To silent this error you check for the existence of observers before calling [rebuildStates]
| ex:
|  if(hasObservers){
|    rebuildStates()
| }
''',
        );
      }
      return true;
    }());

    //used to ensure that [onSetState] is executed only one time.
    bool isOnSetStateCalledOrNull = onSetState == null;

    if (tags == null) {
      _observersMap.forEach(
        (tag, observers) {
          assert(observers != null);
          for (ObserverOfStatesRebuilder observer in observers.reversed) {
            assert(observer != null);
            observer.update(
              isOnSetStateCalledOrNull
                  ? null
                  : (context) {
                      isOnSetStateCalledOrNull = true;
                      onSetState(context);
                    },
            );
          }
        },
      );
      return;
    }

    for (var tag in tags) {
      String _tag;

      if (tag is BuildContext) {
        _tag = 'AutoGeneratedTag#|:${tag.hashCode}';
      } else {
        _tag = tag.toString();
      }

      final observers = _observersMap[_tag];
      if (observers != null) {
        for (ObserverOfStatesRebuilder observer in observers) {
          assert(observer != null);
          observer.update(
            isOnSetStateCalledOrNull
                ? null
                : (context) {
                    isOnSetStateCalledOrNull = true;
                    onSetState(context);
                  },
          );
        }
      }
    }
  }

  ///Add a callback to be executed when all listeners are removed
  void cleaner(VoidCallback voidCallback) {
    _statesRebuilderCleaner.add(voidCallback);
  }
}

//Package private class
class StatesRebuilderInternal {
  static addAllToObserverMap(StatesRebuilder from, StatesRebuilder to) {
    to?._observersMap?.addAll(from._observersMap);
  }
}

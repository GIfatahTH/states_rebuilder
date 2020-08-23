import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

import 'reactive_model.dart';
import 'reactive_model_imp.dart';
import 'state_builder.dart';

///[StatesRebuilder] use the observer pattern.
///
///Observer classes should implement [ObserverOfStatesRebuilder]
abstract class ObserverOfStatesRebuilder {
  ///Method to executed when observer is notified.
  void update(
      [dynamic Function(BuildContext) onSetState, dynamic reactiveModel]);
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
class StatesRebuilder<T> implements Subject {
  ///key holds the observer tags and the value holds the observers
  ///_observers = {"tag" : [observer1, observer2, ...]}
  ///Observers are  automatically add and removed by [StateBuilder] in the [State.initState] and [State.dispose]  methods.
  final LinkedHashMap<String, Set<ObserverOfStatesRebuilder>> _observersMap =
      LinkedHashMap<String, Set<ObserverOfStatesRebuilder>>();
  Set<ObserverOfStatesRebuilder> _observersSet = <ObserverOfStatesRebuilder>{};

  /// observers getter
  Map<String, Set<ObserverOfStatesRebuilder>> observers() => _observersMap;

  ///Check if this observable has observer
  bool get hasObservers => _observersMap.isNotEmpty;

  ///Holds user defined void callback to be executed after removing all observers.
  final Set<VoidCallback> _statesRebuilderCleaner = <VoidCallback>{};

  // static int __observersCount = 0;
  // static set _observersCount(int count) {
  //   assert(count >= 0);
  //   __observersCount = count;
  //   if (__observersCount == 0) {
  //     cleanInjector();
  //   }
  // }

  @override
  void addObserver({ObserverOfStatesRebuilder observer, String tag}) {
    assert(observer != null);
    assert(tag != null);
    _observersSet = {observer, ..._observersSet};
    if (_observersMap[tag] == null) {
      _observersMap[tag] = <ObserverOfStatesRebuilder>{observer};
    } else {
      _observersMap[tag] = {observer, ..._observersMap[tag]};
    }
    // _observersCount = __observersCount + 1;
  }

  @override
  void removeObserver({ObserverOfStatesRebuilder observer, String tag}) {
    assert(
      () {
        if (_observersMap[tag] == null) {
          throw Exception(
            '''

| ***Trying to unregister non registered Tag***
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
    _observersSet.remove(observer);

    // _observersCount = __observersCount - 1;

    if (_observersMap[tag]?.isEmpty == true) {
      _observersMap.remove(tag);
      if (_observersMap.isEmpty) {
        statesRebuilderCleaner(this);
      }
    }
  }

  /// You call [rebuildStates] inside any of your logic classes that extends [StatesRebuilder].
  ///
  /// It will notify observers with [tags] and executed [onSetState] after notification is sent.
  @override
  void rebuildStates([List tags, void Function(BuildContext) onSetState]) {
    assert(() {
      if (RM.debugPrintActiveRM == true) {
        // print(
        //   '$this | filterTags: ${tags != null ? tags : "None"}',
        // );
        if (this is ReactiveModel) {
          final ReactiveModel self = this as ReactiveModel;
          developer.log(
            'RM ${self.type()}. Tag: ${tags == null ? "no tags" : tags}',
            name: 'ReactiveModel Notification',
            error: self.hasData
                ? 'hasData : ${self.state}'
                : self.isIdle
                    ? 'isIdle'
                    : self.isWaiting ? 'isWaiting' : 'hasError : ${self.error}',
          );
        }
      }

      if (!hasObservers) {
        throw Exception(
          '''

***No observer is subscribed yet***
| There is no observer subscribed to this observable $runtimeType model.
| To subscribe a widget you use:
| 1- StateRebuilder for an already defined:
|   ex:
|   StatesRebuilder(
|     observer: () => ${runtimeType}instance,
|     builder : ....
|   )
| 2 - WhenRebuilder, WhenRebuilderOr, OnSetStateListener, StatesWithMixinBuilder are similar to StateBuilder.
| 
| To silent this error you check for the existence of observers before calling [rebuildStates]
| ex:
|  if(hasObservers){
|    rebuildStates()
| }
| or in set the silent parameter of set state to true.
| ex: 
| setState(
|  (s)=> .... ,
|  silent : true,
| )
)
| 
''',
        );
      }
      return true;
    }());
    _notifyingModel = this;
    //used to ensure that [onSetState] is executed only one time.
    bool isOnSetStateCalledOrNull = onSetState == null;

    if (tags == null) {
      for (ObserverOfStatesRebuilder observer in _observersSet) {
        observer.update(
          isOnSetStateCalledOrNull
              ? null
              : (context) {
                  isOnSetStateCalledOrNull = true;
                  onSetState(context);
                },
          this is ReactiveModel ? this : null,
        );
      }

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
          observer.update(
            isOnSetStateCalledOrNull
                ? null
                : (context) {
                    isOnSetStateCalledOrNull = true;
                    onSetState(context);
                  },
            this is ReactiveModel ? this : null,
          );
        }
      }
    }
  }

  ///Add a callback to be executed when all listeners are removed
  void cleaner(VoidCallback voidCallback, [bool remove = false]) {
    if (remove) {
      _statesRebuilderCleaner.remove(voidCallback);
    } else {
      _statesRebuilderCleaner.add(voidCallback);
    }
  }

  static StatesRebuilder _notifyingModel;

  ///Copy the list of observer from this model to the model in the argument
  ///
  ///By default the old list is cleared
  void copy(StatesRebuilder sb, [bool clear = true]) {
    sb._observersMap.addAll(_observersMap);
    sb._observersSet.addAll(_observersSet);
    sb._statesRebuilderCleaner.addAll(_statesRebuilderCleaner);
    if (clear) {
      _observersMap.clear();
      _observersSet.clear();
      _statesRebuilderCleaner.clear();
    }
  }
}

///Package private class
class StatesRebuilderInternal {
  /// get notified model
  static ReactiveModel getNotifiedModel() {
    return StatesRebuilder._notifyingModel is ReactiveModel
        ? StatesRebuilder._notifyingModel as ReactiveModel
        : null;
  }
}

void statesRebuilderCleaner(StatesRebuilder sr, [bool clean = true]) {
  if (sr == null ||
      sr is ReactiveModelImp && sr.numberOfFutureAndStreamBuilder > 0) {
    return;
  }
  if (clean) {
    //Al observers are remove, it is time to execute custom cleaning
    for (final void Function() voidCallBack in [
      ...sr._statesRebuilderCleaner
    ]) {
      if (voidCallBack != null) {
        voidCallBack();
      }
    }
  }
  sr._statesRebuilderCleaner.clear();
  sr._observersMap.clear();
  sr._observersSet.clear();
}

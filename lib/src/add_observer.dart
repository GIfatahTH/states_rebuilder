import 'state_builder.dart';
import 'states_rebuilder.dart';

///A package private class used to add and remove observers to an observable class.
class AddToObserver {
  ///A package private class used to add and remove observers to an observable class.
  AddToObserver(this._widget, this._observer, this._models, [this._uniqueID]) {
    if (_models != null && _models.isNotEmpty) {
      addToObserver();
    }
  }

  ///List of tags
  List<String> tags = <String>[];

  ///The default auto-generated tag
  String defaultTag;
  final StateBuilder<dynamic> _widget;
  final ObserverOfStatesRebuilder _observer;
  final List<StatesRebuilder> _models;
  final String _uniqueID;

  ///Add observer
  void addToObserver() {
    final String _defaultTag = '#@deFau_Lt${_uniqueID}TaG30';

    if (_widget.tag is List) {
      _widget.tag.forEach((dynamic t) {
        if (t != null && t != '') {
          tags.add('$t');
        }
      });
      tags.add(_defaultTag);
    } else {
      if (_widget.tag != null && _widget.tag != '') {
        tags.add(_widget.tag.toString());
      }
      tags.add(_defaultTag);
    }
    for (String t in tags) {
      for (StatesRebuilder model in _models) {
        if (model != null) {
          defaultTag = _defaultTag;
          model.addObserver(
            tag: t,
            observer: _observer,
          );
        }
      }
    }
  }

  ///remove observer
  void removeFromObserver() {
    for (String t in tags) {
      for (StatesRebuilder model in _models) {
        if (model == null) {
          return;
        }
        model.removeObserver(tag: t, observer: _observer);
      }
    }
    tags.clear();
  }
}

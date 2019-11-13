import 'package:states_rebuilder/src/common.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

class SplitAndAddObserver {
  List<String> tag = [];
  String defaultTag;
  final StateBuilderBase _widget;
  final ListenerOfStatesRebuilder _observer;
  List<StatesRebuilder> _models;
  final String uniqueID;

  SplitAndAddObserver(this._widget, this._observer, [this.uniqueID]) {
    _models = _widget.viewModels ?? _widget.models;
    if (_models != null && _models.isNotEmpty) addToObserver();
  }

  void addToObserver() {
    String _defaultTag = "#@deFau_Lt${uniqueID ?? hashCode}TaG30";

    if (_widget.tag is List) {
      _widget.tag.forEach((t) {
        if (t != null && t != "") tag.add("$t");
      });
      tag.add(_defaultTag);
    } else {
      if (_widget.tag != null && _widget.tag != "") {
        _defaultTag = _widget.tag.toString();
      }
      tag.add(_defaultTag);
    }
    for (String t in tag) {
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

  void removeFromObserver() {
    if (_widget.disposeViewModels == true) {
      _models?.forEach((model) => (model as dynamic).dispose());
    }
    for (String t in tag) {
      for (StatesRebuilder model in _models) {
        if (model == null) return;
        model.removeObserver(tag: t, observer: _observer);
      }
    }
    tag.clear();
  }
}

import 'package:states_rebuilder/src/common.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

class SplitAndAddObserver {
  List<String> tag = [];
  String tagID;
  final StateBuilderBase _widget;
  final ListenerOfStatesRebuilder _observer;
  final String _uniqueID;
  List<StatesRebuilder> _models;

  SplitAndAddObserver(this._widget, this._observer, this._uniqueID) {
    _models = _widget.viewModels ?? _widget.blocs;
    addToObserver();
  }

  void addToObserver() {
    List<String> listOfTags = [];

    if (_widget.tag is List) {
      _widget.tag.forEach((t) {
        (t != null && t != "") ? listOfTags.add("$t") : listOfTags.add(null);
      });
    } else {
      (_widget.tag != null && _widget.tag != "")
          ? listOfTags.add(_widget.tag.toString())
          : listOfTags.add(null);
    }
    for (String t in listOfTags) {
      if (_models == null || _models.isEmpty) return;
      for (StatesRebuilder model in _models) {
        if (model == null) continue;
        this.tag.add((t != null) ? "$t" : "#@deFau_Lt${model.hashCode}TaG30");

        model.addObserver(
          tag: this.tag.last,
          tagID: _uniqueID,
          observer: _observer,
        );
      }
    }
    tagID =
        this.tag.isNotEmpty ? "${this.tag?.first}$splitter$_uniqueID" : null;
  }

  void removeFromObserver() {
    if (_widget.disposeViewModels == true) {
      _models?.forEach((model) => (model as dynamic).dispose());
    }

    for (String t in tag) {
      for (StatesRebuilder model in _models) {
        if (model == null) return;
        model.removeObserver(tag: t, tagID: _uniqueID);
      }
    }
    tag.clear();
  }
}

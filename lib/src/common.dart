import 'package:flutter/material.dart';
import 'states_rebuilder.dart';

typedef StateBuildertype = Widget Function(BuildContext context, String tagID);

abstract class StateBuilderBase extends StatefulWidget {
  StateBuilderBase({
    Key key,
    this.tag,
    this.blocs,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  final StateBuildertype builder;
  final dynamic tag;
  final List<StatesRebuilder> blocs;
}

List<String> addListener(List<StatesRebuilder> widgetBlocs, dynamic widgetTag,
    String hashcode, VoidCallback listener) {
  String tag, _tagID;

  if (widgetBlocs != null) {
    widgetBlocs.forEach(
      (StatesRebuilder b) {
        if (b == null) return null;
        tag = (widgetTag != null && widgetTag != "")
            ? "$widgetTag"
            : "#@dFau_Lt${b.hashCode}TaG30";
        _tagID = "$tag${b.spliter}$hashcode";
        b.addToListeners(tag: tag, listener: listener, hashcode: hashcode);
      },
    );
  }
  return [tag, _tagID];
}

void removeListner(
  List<StatesRebuilder> widgetBlocs,
  String tag,
  int hashcode,
  VoidCallback listener,
) {
  if (widgetBlocs != null) {
    widgetBlocs.forEach(
      (StatesRebuilder b) {
        if (b == null) return;
        if (tag == null) return;
        b.removeFromListeners(tag, "$hashcode");
      },
    );
  }
}

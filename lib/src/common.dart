import 'package:flutter/material.dart';

import 'states_rebuilder.dart';

typedef StateBuilderType = Widget Function(BuildContext context, String tagID);

abstract class StateBuilderBase extends StatefulWidget {
  StateBuilderBase({
    Key key,
    this.tag,
    this.blocs,
    this.viewModels,
    this.disposeViewModels = false,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  final StateBuilderType builder;
  final dynamic tag;
  final List<StatesRebuilder> blocs;
  final List<StatesRebuilder> viewModels;
  final bool disposeViewModels;
}

List<String> addListener(List<StatesRebuilder> widgetVM, dynamic widgetTag,
    String hashCode, VoidCallback listener) {
  String tag, _tagID;

  if (widgetVM != null) {
    widgetVM.forEach(
      (StatesRebuilder b) {
        if (b == null) return null;
        tag = (widgetTag != null && widgetTag != "")
            ? "$widgetTag"
            : "#@dFau_Lt${b.hashCode}TaG30";
        _tagID = "$tag$splitter$hashCode";
        StatesRebuilder.addToListeners(
            viewModel: b, tag: tag, listener: listener, hashCode: hashCode);
      },
    );
  }
  return [tag, _tagID];
}

void removeListener(
  List<StatesRebuilder> widgetVM,
  String tag,
  String uniqueID,
  VoidCallback listener,
) {
  if (widgetVM != null) {
    widgetVM.forEach(
      (StatesRebuilder b) {
        if (b == null) return;
        if (tag == null) return;
        StatesRebuilder.removeFromListeners(b, tag, uniqueID);
      },
    );
  }
}

String splitter = "";

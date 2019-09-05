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

abstract class Subject {
  void rebuildStates([List<dynamic> tags]);

  void addObserver({
    @required ListenerOfStatesRebuilder observer,
    @required String tag,
    @required String tagID,
  });

  void removeObserver({
    @required String tag,
    @required String tagID,
  });
}

String splitter = "";

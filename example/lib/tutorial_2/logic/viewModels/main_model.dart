import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../enums/tag_enums.dart';

class MainModel extends StatesRebuilder {
  TabController tabController;

  initState(TickerProvider ticker, length) {
    tabController = TabController(vsync: ticker, length: length);
    tabController.addListener(() {
      rebuildStates([MainTag.appBar]);
    });
  }

  dispose() {
    tabController.dispose();
    print("tab Controller is disposed");
  }
}

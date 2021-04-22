import 'dart:async';

import 'package:flutter/material.dart';

import '../rm.dart';

class StatesRebuilder extends Injected {
  void rebuildStates([List? tags]) {}
  int get observerLength => 0;
  @override
  bool get canRedoState => throw UnimplementedError();

  @override
  bool get canUndoState => throw UnimplementedError();

  @override
  void clearUndoStack() {}

  @override
  void deletePersistState() {}

  @override
  Widget inherited(
      {required Widget Function(BuildContext p1) builder,
      Key? key,
      FutureOr Function()? stateOverride,
      bool connectWithGlobal = true,
      String? debugPrintWhenNotifiedPreMessage,
      String Function(dynamic s)? toDebugString}) {
    throw UnimplementedError();
  }

  @override
  void injectFutureMock(Future Function() fakeCreator) {}

  @override
  void injectMock(Function() fakeCreator) {}

  @override
  void injectStreamMock(Stream Function() fakeCreator) {}

  @override
  void persistState() {}

  @override
  Widget reInherited(
      {Key? key,
      required BuildContext context,
      required Widget Function(BuildContext p1) builder}) {
    throw UnimplementedError();
  }

  @override
  void redoState() {}

  @override
  void undoState() {}
}

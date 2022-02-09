part of '../rm.dart';

const deepEquality = DeepCollectionEquality();
bool isObjectOrNull<T>() {
  return T == Object || T == typeDef<Object?>();
}

Type typeDef<T>() => T;

final List<BuildContext> _contextSet = [];

VoidCallback addToContextSet(BuildContext ctx) {
  _contextSet.add(ctx);
  // print('contextSet length is ${_contextSet.length}');
  return () {
    _contextSet.remove(ctx);
    // print('contextSet dispose length is ${_contextSet.length}');
  };
}

final injectedModels = <ReactiveModelImp<dynamic>>{};
VoidCallback addToActiveReactiveModels(ReactiveModelImp<dynamic> inj) {
  injectedModels.add(inj);

  return () {
    injectedModels.remove(inj);
  };
}

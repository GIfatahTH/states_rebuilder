import 'package:collection/collection.dart';

const deepEquality = DeepCollectionEquality();
bool isObjectOrNull<T>() {
  return T == Object || T == _typeDef<Object?>();
}

Type _typeDef<T>() => T;

// import 'package:flutter/widgets.dart';
// import 'package:collection/collection.dart';

// import 'inject.dart';
// import 'reactive_model.dart';
// import 'reactive_model_imp.dart';

// ///A package private class used to add reactive environment to Stream and future
// class ReactiveModelStream<T> extends ReactiveModelImp<T> {
//   ///A package private class used to add reactive environment to Stream and future

//   ReactiveModelStream(this.injectAsync, [bool isNewReactiveInstance = false])
//       : super(injectAsync, isNewReactiveInstance) {
//     streamSubscribe();
//   }

//   ///Injector associated with this ReactiveModel
//   Inject<T> injectAsync;
//   Object Function(T) _watch;
//   Stream<T> _stream;
//   ReactiveModel _reactiveModel;

//   ///Get Global ReactiveModel
//   ReactiveModel get reactiveModel =>
//       _reactiveModel ??= injectAsync.getReactive();

//   dynamic _watchCached;
//   bool _hasError = false;

//   ///subscribe to the stream
//   void streamSubscribe() {
//     if (injectAsync.isFutureType) {
//       stateFuture = injectAsync.creationFutureFunction();
//       _stream = stateFuture.asStream();
//     } else {
//       _stream = injectAsync.creationStreamFunction();
//     }
//     assert(_stream != null);

//     state = injectAsync.initialValue;
//     snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, state);

//     _watch = injectAsync.watch;

//     _watchCached = _watch?.call(snapshot.data);

//     subscription = _stream.listen(
//       (data) {
//         bool canRebuild() {
//           if (_watch == null) {
//             return true;
//           }
//           bool canRebuild;
//           final _watchActual = _watch?.call(snapshot.data);
//           canRebuild = !(const DeepCollectionEquality())
//               .equals(_watchActual, _watchCached);
//           _watchCached = _watchActual;
//           return canRebuild;
//         }

//         state = data;
//         snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, state);
//         if (_hasError || _watch == null || canRebuild()) {
//           if (reactiveModel.hasObservers) {
//             reactiveModel.rebuildStates(injectAsync.filterTags);
//           }
//           _hasError = false;
//         }
//       },
//       onError: (dynamic e) {
//         snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
//         _hasError = true;

//         if (reactiveModel.hasObservers) {
//           reactiveModel.rebuildStates(
//             injectAsync.filterTags,
//             (context) {
//               onErrorHandler?.call(context, e);
//             },
//           );
//         } else {
//           onErrorHandler?.call(null, e);
//         }
//       },
//       onDone: () {
//         snapshot = snapshot.inState(ConnectionState.done);
//         if (reactiveModel.hasObservers && !injectAsync.isFutureType) {
//           isStreamDone = true;
//           reactiveModel.rebuildStates(injectAsync.filterTags);
//         }
//       },
//       cancelOnError: false,
//     );
//     snapshot = snapshot.inState(ConnectionState.waiting);
//   }
// }

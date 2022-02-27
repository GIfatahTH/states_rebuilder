part of 'injected_text_editing.dart';

/// Listen to a InjectedForm and rebuild depending on Form submission state
class OnFormSubmissionBuilder extends MyStatefulWidget {
  /// Listen to a InjectedForm and rebuild depending on Form submission state
  OnFormSubmissionBuilder({
    Key? key,
    required this.listenTo,
    required this.onSubmitting,
    this.onSubmissionError,
    required this.child,
  }) : super(
          observers: (_) {
            return [listenTo as ReactiveModelImp];
          },
          // shouldRebuild: (old, current) {
          //   final inj = listenTo as InjectedFormImp;
          //   if (inj.isWaiting) {
          //     inj.onSubmitting?.call();
          //   }
          //   return true;
          // },
          builder: (context, snap, rm) {
            final inj = listenTo as InjectedFormImp;

            if (inj.isWaiting) {
              return onSubmitting();
            }
            if (inj.hasError && onSubmissionError != null) {
              return onSubmissionError(
                inj.error,
                inj.snapValue.snapError!.refresher,
              );
            }
            return child;
          },
          key: key,
        );

  /// InjectedForm to listen to
  final InjectedForm listenTo;

  ///Widget to display while waiting for submission
  final Widget Function() onSubmitting;

  ///Widget to display if submission fails, you can resubmit with the last valid
  ///parameters using the onRefresh callback

  final Widget Function(dynamic error, VoidCallback onRefresh)?
      onSubmissionError;

  /// the Child widget
  final Widget child;
}

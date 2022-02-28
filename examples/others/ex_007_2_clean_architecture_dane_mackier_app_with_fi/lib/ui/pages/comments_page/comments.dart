part of 'comments_page.dart';

class _Comments extends ReactiveStatelessWidget {
  final int postId;
  _Comments(this.postId);
  @override
  void didMountWidget(context) {
    commentsBloc.read(postId);
  }

  @override
  void didNotifyWidget(SnapState snap) {
    snap.onOrElse(
      onError: (err, refresh) => ExceptionHandler.showErrorDialog(err),
      orElse: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return commentsBloc.commentsRM.onAll(
      onWaiting: () => Center(child: CircularProgressIndicator()),
      onError: (err, refresh) => Center(
        child: Text('${err.message}'),
      ),
      onData: (comments) {
        return Expanded(
          child: ListView(
            children: comments
                .map(
                  (comment) => _CommentItem(comment),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

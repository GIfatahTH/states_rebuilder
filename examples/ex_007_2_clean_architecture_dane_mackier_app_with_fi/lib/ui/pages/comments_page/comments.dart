part of 'comments_page.dart';

class _Comments extends StatelessWidget {
  final int postId;
  _Comments(this.postId);

  @override
  Widget build(BuildContext context) {
    return OnReactive(
      () => commentsInj.onAll(
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
      ),
      sideEffects: SideEffects(
        initState: () => commentsInj.crud.read(param: (_) => postId),
        onSetState: (snap) {
          snap.onOrElse(
            onError: (err, refresh) => ExceptionHandler.showErrorDialog(err),
            orElse: (_) {},
          );
        },
      ),
    );
  }
}

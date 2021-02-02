part of 'comments_page.dart';

class _Comments extends StatelessWidget {
  final int postId;
  _Comments(this.postId);

  @override
  Widget build(BuildContext context) {
    return On.all(
      onIdle: () => Container(),
      onWaiting: () => Center(child: CircularProgressIndicator()),
      onError: (err) => Center(
        child: Text('${err.message}'),
      ),
      onData: () {
        return Expanded(
          child: ListView(
            children: commentsInj.state
                .map((comment) => _CommentItem(comment))
                .toList(),
          ),
        );
      },
    ).listenTo(
      commentsInj,
      initState: () => commentsInj.crud.read(param: (_) => postId),
      onSetState: On.error(ExceptionHandler.showErrorDialog),
    );
  }
}

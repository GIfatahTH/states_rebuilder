part of 'comments_page.dart';

class _LikeButton extends StatelessWidget {
  _LikeButton({
    required this.postId,
  });
  final int postId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        On.data(
          () => Text('Likes ${postsInj.state.getPostLikes(postId)}'),
        ).listenTo(postsInj),
        MaterialButton(
          color: Colors.white,
          child: Icon(Icons.thumb_up),
          onPressed: () {
            postsInj.setState((state) => state.incrementLikes(postId));
          },
        )
      ],
    );
  }
}

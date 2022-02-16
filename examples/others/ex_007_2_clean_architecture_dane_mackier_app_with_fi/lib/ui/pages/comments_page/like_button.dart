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
        OnReactive(
          () => Text('Likes ${postsBloc.getPostLikes(postId)}'),
        ),
        MaterialButton(
          color: Colors.white,
          child: Icon(Icons.thumb_up),
          onPressed: () {
            postsBloc.incrementLikes(postId);
          },
        )
      ],
    );
  }
}

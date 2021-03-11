part of 'posts_page.dart';

final postsInj = RM.injectCRUD(
  () => PostRepository(),
  param: () => userInj.state.id,
  readOnInitialization: true,
  onSetState: On.error(
    (err, refresh) => ExceptionHandler.showErrorDialog(err),
  ),
  // debugPrintWhenNotifiedPreMessage: '',
);

extension PostsX on List<Post> {
  int getPostLikes(postId) {
    return firstWhere((post) => post.id == postId).likes;
  }

  void incrementLikes(int postId) {
    firstWhere((post) => post.id == postId).incrementLikes();
  }
}

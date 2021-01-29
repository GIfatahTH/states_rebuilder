import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/api.dart';
import 'domain/entities/post.dart';
import 'domain/entities/user.dart';
import 'ui/exceptions/error_handler.dart';

final userInj = RM.injectCRUD<User, int>(
  () => UserRepository(),
  onSetState: On.or(
    onError: (err) => ErrorHandler.showSnackBar(err),
    onData: () => RM.navigate.toNamed(('/')),
    or: () {},
  ),
  // debugPrintWhenNotifiedPreMessage: '',
);

final postsInj = RM.injectCRUD(
  () => PostRepository(),
  param: () => userInj.state.first.id,
  readOnInitialization: true,
  onSetState: On.error(
    (err) => ErrorHandler.showErrorDialog(err),
  ),
);

extension PostsX on List<Post> {
  int getPostLikes(postId) {
    return firstWhere((post) => post.id == postId).likes;
  }

  void incrementLikes(int postId) {
    firstWhere((post) => post.id == postId).incrementLikes();
  }
}

final commentsInj = RM.injectCRUD(
  () => CommentRepository(),
  // debugPrintWhenNotifiedPreMessage: '',
);

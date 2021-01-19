import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/api.dart';
import 'domain/entities/comment.dart';
import 'domain/entities/post.dart';
import 'ui/exceptions/error_handler.dart';

final userInj = RM.injectCRUD(
  () => UserRepository(),
  id: (user) => user.id,
  onSetState: On.error(
    (err) => ErrorHandler.showSnackBar(err),
  ),
);

final InjectedCRUD<Post, int> postsInj = RM.injectCRUD(
  () => PostRepository(),
  id: (post) => post.id,
  onInitialized: (_) => postsInj.setState(
    (s) => postsInj.crud.read(userInj.state.first.id),
  ),
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

final InjectedCRUD<Comment, int> commentsInj = RM.injectCRUD(
  () => CommentRepository(),
  id: (comment) => comment.id,
  onInitialized: (_) => commentsInj.setState(
    (s) => commentsInj.crud.read(postsInj.state.first.id),
  ),
);

// final _api = RM.inject(
//   () => Api(),
// );

// final authenticationService = RM.inject(
//   () => AuthenticationService(api: _api.state),
// );

// final postsService = RM.inject(
//   () => PostsService(api: _api.state),
// );

// final commentsService = RM.inject(
//   () => CommentsService(api: _api.state),
// );

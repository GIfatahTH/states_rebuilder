import 'package:states_rebuilder/states_rebuilder.dart';

import 'post.dart';
import 'posts_repository.dart';

final posts = RM.injectCRUD<Post, int>(
  () => FakePostsRepository(),
  readOnInitialization: true,
  param: () => 0,
  stateInterceptor: (current, nextSnap) {
    if (!nextSnap.hasData) return nextSnap;
    if (current.state.isNotEmpty && nextSnap.state.isEmpty) {
      hasReachedMax = true;
      return current.copyToHasData(current.state);
    }
    hasReachedMax = false;
    return nextSnap.copyToHasData([...current.state, ...nextSnap.state]);
  },
  debugPrintWhenNotifiedPreMessage: '',
  toDebugString: (List<Post>? s) => '${s?.length}',
);

bool hasReachedMax = false;

extension PostsX on List<Post> {
  void fetchMorePosts() {
    posts.crud.read(
      param: (_) => posts.state.length,
    );
  }
}

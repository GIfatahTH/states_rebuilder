import 'package:ex_006_2_infinite_scroll_list/posts_repository.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'post.dart';

final scroll = RM.injectScrolling(onScrolling: (scroll) {
  if (posts.customStatus == 'hasReachedMax' || posts.isWaiting) {
    return;
  }
  if (scroll.hasReachedMaxExtent) {
    posts.state.fetchMorePosts();
  }
});
final posts = RM.injectCRUD<Post, int>(
  () => FakePostsRepository(),
  readOnInitialization: true,
  param: () => 0,
  debugPrintWhenNotifiedPreMessage: '',
  toDebugString: (List<Post>? s) => '${s?.length}',
);

extension PostsX on List<Post> {
  void fetchMorePosts() {
    posts.crud.read(
      param: (_) => posts.state.length,
      middleState: (state, nextState) {
        if (nextState.isEmpty) {
          posts.customStatus = 'hasReachedMax';
          return state;
        }
        return [...state, ...nextState];
      },
    );
  }
}

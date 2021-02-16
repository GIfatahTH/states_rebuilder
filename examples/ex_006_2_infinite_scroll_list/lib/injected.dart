import 'package:ex_006_2_infinite_scroll_list/posts_repository.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'post.dart';

final posts = RM.injectCRUD<Post, int>(
  () => FakePostsRepository(),
  readOnInitialization: true,
  param: () => 0,
  middleSnapState: (snap) {
    snap.print(
      stateToString: (List<Post>? s) => '${s?.length}',
    );
  },
);

extension PostsX on List<Post> {
  static bool _canScroll = true;
  bool get canScroll => _canScroll && !posts.isWaiting;
  void refresh() => _canScroll = true;
  void fetchMorePosts() {
    posts.crud.read(
      param: (_) => posts.state.length,
      middleState: (state, nextState) {
        if (nextState.isEmpty) {
          _canScroll = false;
          return state;
        }
        return [...state, ...nextState];
      },
    );
  }
}

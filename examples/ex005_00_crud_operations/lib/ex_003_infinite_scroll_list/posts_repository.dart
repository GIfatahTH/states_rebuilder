import 'dart:math' as math;

import 'package:states_rebuilder/states_rebuilder.dart';

import 'post.dart';

const postLimit = 10;

class FakePostsRepository implements ICRUD<Post, int> {
  final _posts = List.generate(
    100,
    (index) => Post(
      id: index + 1,
      title:
          'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam',
      body:
          'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et',
    ),
  );

  @override
  Future<List<Post>> read([int? startIndex]) async {
    await Future.delayed(Duration(milliseconds: 500));
    // if (math.Random().nextBool()) {
    //   throw Exception('NetWork failure');
    // }
    startIndex ??= 0;
    if ((startIndex) >= _posts.length) {
      return [];
    }

    final result = _posts.sublist(
      startIndex,
      math.min(startIndex + postLimit, _posts.length),
    );
    return result;
  }

  @override
  Future<Post> create(Post item, int? param) {
    throw UnimplementedError();
  }

  @override
  Future update(List<Post> items, int? param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<Post> items, int? param) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}

  @override
  Future<void> init() async {}
}


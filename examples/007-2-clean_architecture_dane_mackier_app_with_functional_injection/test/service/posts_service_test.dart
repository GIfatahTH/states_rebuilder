import 'package:clean_architecture_dane_mackier_app/service/posts_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data_source/fake_api.dart';

void main() {
  test('commentsService', () async {
    final postsService = PostsService(api: FakeApi());

    await postsService.getPostsForUser(1);

    expect(postsService.posts.length, equals(1));
    expect(postsService.posts.first.title, equals('Fake title'));
  });

  test('getPostLikes and incrementLikes', () async {
    final postsService = PostsService(api: FakeApi());

    await postsService.getPostsForUser(1);

    expect(postsService.getPostLikes(1), equals(0));

    postsService.incrementLikes(1);

    expect(postsService.getPostLikes(1), equals(1));
  });
}

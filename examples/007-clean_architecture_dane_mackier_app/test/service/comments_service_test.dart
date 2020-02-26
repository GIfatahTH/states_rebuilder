import 'package:clean_architecture_dane_mackier_app/service/comments_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data_source/fake_api.dart';

void main() {
  test('commentsService', () async {
    final commentsService = CommentsService(api: FakeApi());

    await commentsService.fetchComments(1);

    expect(commentsService.comments.length, equals(1));
    expect(commentsService.comments.first.name, equals('Fake comment'));
  });
}

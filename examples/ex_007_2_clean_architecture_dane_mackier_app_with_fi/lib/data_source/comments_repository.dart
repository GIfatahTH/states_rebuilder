part of 'api.dart';

class CommentRepository implements ICRUD<Comment, int> {
  @override
  Future<List<Comment>> read([int? postId]) async {
    if (postId == null) {
      throw NullNumberException();
    }
    var comments = <Comment>[];

    try {
      final response = await _client.get(
        Uri.parse('$_endpoint/comments?postId=$postId'),
      );
      if (response.statusCode == 404) {
        throw CommentNotFoundException(postId);
      }

      if (response.statusCode != 200) {
        throw NetworkErrorException();
      }

      var parsed = json.decode(response.body) as List<dynamic>;

      for (var comment in parsed) {
        comments.add(Comment.fromMap(comment));
      }

      return comments;
    } catch (e) {
      throw NetworkErrorException();
    }
  }

  @override
  Future<Comment> create(Comment item, int? param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<Comment> items, int? param) {
    throw UnimplementedError();
  }

  @override
  Future update(List<Comment> items, int? param) {
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {}
  @override
  void dispose() {}
}

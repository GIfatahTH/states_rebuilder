part of 'api.dart';

class CommentRepository implements ICRUD<Comment, int> {
  @override
  Future<List<Comment>> read([int? postId]) async {
    if (postId == null) {
      throw NullNumberException();
    }
    var comments = <Comment>[];

    http.Response response;
    try {
      response = await _client.get(
        Uri.parse('$_endpoint/comments?postId=$postId'),
      );
    } catch (e) {
      throw NetworkErrorException();
    }
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
  }

  @override
  Future<Comment> create(Comment item, int? param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<Comment> items, int? param) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future update(List<Comment> items, int? param) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {}
  @override
  void dispose() {}
}

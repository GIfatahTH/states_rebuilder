part of 'api.dart';

class PostRepository implements ICRUD<Post, int> {
  @override
  Future<List<Post>> read([int? userId]) async {
    if (userId == null) {
      throw NullNumberException();
    }
    var posts = <Post>[];
    try {
      final response = await _client.get(
        Uri.parse('$_endpoint/posts?userId=$userId'),
      );
      if (response.statusCode == 404) {
        throw PostNotFoundException(userId);
      }

      if (response.statusCode != 200) {
        throw NetworkErrorException();
      }

      var parsed = json.decode(response.body) as List<dynamic>;

      for (var post in parsed) {
        posts.add(Post.fromMap(post));
      }

      return posts;
    } catch (e) {
      throw NetworkErrorException();
    }
  }

  @override
  Future<Post> create(Post item, int? param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<Post> items, int? param) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future update(List<Post> items, int? param) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {}
  @override
  void dispose() {}
}

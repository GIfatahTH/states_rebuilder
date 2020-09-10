import '../domain/entities/comment.dart';
import 'interfaces/i_api.dart';

//use case : Fetch comments by post ID, cache the obtained comment list in memory
class CommentsService {
  IApi _api;
  CommentsService({IApi api}) : _api = api;

  List<Comment> _comments;
  List<Comment> get comments => _comments;

  Future<void> fetchComments(int postId) async {
    _comments = await _api.getCommentsForPost(postId);
  }
}

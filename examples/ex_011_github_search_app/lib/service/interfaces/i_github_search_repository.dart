import '../../domain/entities/github_user.dart';

abstract class IGitHubSearchRepository {
  Future<List<GitHubUser>> searchUser(String username);
}

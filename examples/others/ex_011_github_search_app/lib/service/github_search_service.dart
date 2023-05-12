import '../domain/entities/github_user.dart';
import 'interfaces/i_github_search_repository.dart';

class GitHubSearchService {
  final IGitHubSearchRepository gitHubSearchRepository;

  GitHubSearchService({required this.gitHubSearchRepository});

  Future<List<GitHubUser>> searchUser(String userName) async {
    if (userName.isEmpty) {
      return [];
    }
    return gitHubSearchRepository.searchUser(userName);
  }
}

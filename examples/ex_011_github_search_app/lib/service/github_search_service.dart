import 'package:flutter/foundation.dart';

import '../domain/entities/github_user.dart';
import 'interfaces/i_github_search_repository.dart';

class GitHubSearchService {
  final IGitHubSearchRepository gitHubSearchRepository;

  GitHubSearchService({@required this.gitHubSearchRepository});

  Future<List<GitHubUser>> searchUser(String userName) async {
    return gitHubSearchRepository.searchUser(userName);
  }
}

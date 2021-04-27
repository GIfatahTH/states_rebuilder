import 'package:github_search_app/domain/entities/github_user.dart';
import 'package:github_search_app/service/interfaces/i_github_search_repository.dart';

class FakeGitHubSearchRepository implements IGitHubSearchRepository {
  @override
  Future<List<GitHubUser>> searchUser(String username) async {
    await Future.delayed(Duration(seconds: 1));
    return data
        .where((e) => e.startsWith(username))
        .map((e) =>
            GitHubUser(login: e, avatarUrl: 'avatarImage', htmlUrl: 'htmlUrl'))
        .toList();
  }

  final data = [
    'Dorie Nelligan',
    'Janine Pettey',
    'Ji Hadsell',
    'Palmer Deatherage',
    'Dionne Hakala',
    'Lyndon Fabry',
    'Frieda Huneke',
    'Lakeesha Walts',
    'Cherelle Kenyon',
    'Janine Ballin',
  ];
}

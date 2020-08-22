import 'dart:convert';

import 'package:github_search_app/domain/entities/github_user.dart';
import 'package:github_search_app/service/exceptions/github_api_error.dart';
import 'package:github_search_app/service/interfaces/i_github_search_repository.dart';
import 'package:http/http.dart' as http;

class GitHubSearchRepository implements IGitHubSearchRepository {
  @override
  Future<List<GitHubUser>> searchUser(String username) async {
    final uri = _searchUsernameUri(username);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      if (items?.isNotEmpty ?? false) {
        return items.map((item) => GitHubUser.fromMap(item)).toList();
      }
      throw GitHubAPIError.parseError();
    }
    if (response.statusCode == 403) {
      throw GitHubAPIError.rateLimitExceeded();
    }
    print(
        'Request $uri failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
    throw GitHubAPIError.unknownError();
  }

  Uri _searchUsernameUri(String username) => Uri(
        scheme: 'https',
        host: 'api.github.com',
        path: 'search/users',
        queryParameters: {'q': username},
      );
}

import 'package:flutter/foundation.dart';

class GitHubUser {
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  GitHubUser({
    @required this.login,
    @required this.avatarUrl,
    @required this.htmlUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'login': login,
      'avatarUrl': avatarUrl,
      'htmlUrl': htmlUrl,
    };
  }

  factory GitHubUser.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return GitHubUser(
      login: map['login'],
      avatarUrl: map['avatar_url'],
      htmlUrl: map['html_url'],
    );
  }

  @override
  String toString() =>
      'GitHubUser(login: $login, avatarUrl: $avatarUrl, htmlUrl: $htmlUrl)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is GitHubUser &&
        o.login == login &&
        o.avatarUrl == avatarUrl &&
        o.htmlUrl == htmlUrl;
  }

  @override
  int get hashCode => login.hashCode ^ avatarUrl.hashCode ^ htmlUrl.hashCode;
}

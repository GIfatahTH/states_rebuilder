import 'package:flutter/material.dart';
import 'package:github_search_app/domain/entities/github_user.dart';

import '../../../injected.dart';

class GitHubUserSearchResultTile extends StatelessWidget {
  const GitHubUserSearchResultTile(
      {@required this.user, @required this.onSelected});

  final GitHubUser user;
  final ValueChanged<GitHubUser> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: () => onSelected(user),
      child: Column(
        children: [
          ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Container(
              child: isTestMode
                  ? Container()
                  : Image.network(
                      user.avatarUrl,
                    ),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            user.login,
            style: theme.textTheme.headline6,
            textAlign: TextAlign.start,
          )
        ],
      ),
    );
  }
}

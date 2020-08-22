import 'package:flutter/material.dart';
import 'package:github_search_app/domain/entities/github_user.dart';

import 'github_search_delegate.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Search'),
      ),
      body: Center(
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          child: Text('Search',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.white)),
          onPressed: () async {
            final user = await showSearch<GitHubUser>(
              context: context,
              delegate: GitHubSearchDelegate(),
            );

            print(user);
          },
        ),
      ),
    );
  }
}

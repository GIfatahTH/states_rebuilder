import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/github_user.dart';
import '../../../injected.dart';
import '../../widgets/search_placeholder.dart';
import 'github_search_result_tile.dart';

class GitHubSearchDelegate extends SearchDelegate<GitHubUser> {
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(key: Key('__Container__'));
    }
    //set the state of userNameQuery using setState here,
    //because we want to debounce the setState call;
    userNameQuery.setState(
      (s) => query.trim(),
      debounceDelay: 500,
    );

    return buildMatchingSuggestions(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Container(key: Key('__Container__'));
    }

    // always search if submitted
    //No need to debounce the fetch of users
    userNameQuery.state = query.trim();

    return buildMatchingSuggestions(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isEmpty
        ? []
        : <Widget>[
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
          ];
  }

  Widget buildMatchingSuggestions(BuildContext context) {
    // subscribe to fetchedGitHubUser using whenRebuilder
    return On.all(
      onIdle: () => Text('Idle'),
      onWaiting: () => Center(child: CircularProgressIndicator()),
      onData: () => GridView.builder(
        itemCount: fetchedGitHubUser.state.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return GitHubUserSearchResultTile(
            user: fetchedGitHubUser.state[index],
            onSelected: (value) => close(context, value),
          );
        },
      ),
      onError: (error, refresh) => SearchPlaceholder(title: '$error'),
    ).listenTo(fetchedGitHubUser);
  }
}

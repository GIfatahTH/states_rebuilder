import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'injected.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Posts infinite scroll list'),
        ),
        body: PostsPage(),
      ),
    );
  }
}

final _controller = ScrollController();

class PostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return On.or(
      onError: (err, refresh) => Center(
        child: Row(
          children: [
            Text('failed to fetch posts'),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => refresh(),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      or: () {
        if (posts.state.isEmpty) {
          if (posts.isWaiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('no posts'));
        }

        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return index < posts.state.length
                ? ListTile(
                    leading: Text('${posts.state[index].id}'),
                    title: Text(posts.state[index].title),
                    subtitle: Text(posts.state[index].body),
                  )
                : posts.argument != 'hasReachedMax'
                    ? On.or(
                        onError: (err, refresh) => ElevatedButton(
                          onPressed: () => refresh(),
                          child: Text('Refresh Error'),
                        ),
                        or: () => Center(
                          child: CircularProgressIndicator(),
                        ),
                      ).listenTo(posts)
                    : ElevatedButton(
                        onPressed: () {
                          posts.refresh();
                        },
                        child: Text('Refresh Posts'),
                      );
          },
          itemCount: posts.state.length + 1,
          controller: _controller,
        );
      },
    ).listenTo(
      posts,
      initState: () => _controller.addListener(_onScroll),
      dispose: () => _controller.dispose(),
    );
  }

  void _onScroll() {
    if (posts.argument == 'hasReachedMax' || posts.isWaiting) {
      return;
    }
    if (_controller.offset >= _controller.position.maxScrollExtent) {
      posts.state.fetchMorePosts();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'injected.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Posts infinite scroll list'),
        ),
        body: const PostsPage(),
      ),
    );
  }
}

class PostsPage extends ReactiveStatelessWidget {
  const PostsPage({Key? key}) : super(key: key);

  static late ScrollController scrollController;
  @override
  void didMountWidget(BuildContext context) {
    scrollController = ScrollController();
    scrollController.addListener(
      () {
        if (posts.isWaiting) return;
        if (scrollController.offset >
            scrollController.position.maxScrollExtent - 10) {
          posts.state.fetchMorePosts();
        }
      },
    );
  }

  @override
  void didUnmountWidget() {
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (posts.state.isEmpty) {
      if (posts.isWaiting) {
        return const Center(child: CircularProgressIndicator());
      }
      return const Center(child: Text('no posts'));
    }

    return posts.onOrElse(
      onError: (err, refresh) => Center(
        child: Row(
          children: [
            const Text('failed to fetch posts'),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => refresh(),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      orElse: (data) {
        return ListView.builder(
          controller: scrollController,
          itemCount: data.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return index < data.length
                ? ListTile(
                    leading: Text('${data[index].id}'),
                    title: Text(data[index].title),
                    subtitle: Text(data[index].body),
                  )
                : !hasReachedMax
                    ? posts.onOrElse(
                        onError: (err, refresh) => ElevatedButton(
                              onPressed: () => refresh(),
                              child: const Text('Refresh Error'),
                            ),
                        onWaiting: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        orElse: (_) => const SizedBox.shrink())
                    : ElevatedButton(
                        onPressed: () {
                          posts.customStatus = null;
                          posts.refresh();
                        },
                        child: const Text('Refresh Posts'),
                      );
          },
        );
      },
    );
  }
}

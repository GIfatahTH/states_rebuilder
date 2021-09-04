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

class PostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnReactive(
      () {
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
                Text('failed to fetch posts'),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => refresh(),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          orElse: (data) {
            return ListView.builder(
              controller: scroll.controller,
              itemCount: data.length + 1,
              itemBuilder: (BuildContext context, int index) {
                return index < data.length
                    ? ListTile(
                        leading: Text('${data[index].id}'),
                        title: Text(data[index].title),
                        subtitle: Text(data[index].body),
                      )
                    : posts.customStatus != 'hasReachedMax'
                        ? posts.onOrElse(
                            onError: (err, refresh) => ElevatedButton(
                              onPressed: () => refresh(),
                              child: Text('Refresh Error'),
                            ),
                            orElse: (_) => Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              posts.customStatus = null;
                              posts.refresh();
                            },
                            child: Text('Refresh Posts'),
                          );
              },
            );
          },
        );
      },
      sideEffects: SideEffects(
        dispose: () => scroll.dispose(),
      ),
    );
  }
}

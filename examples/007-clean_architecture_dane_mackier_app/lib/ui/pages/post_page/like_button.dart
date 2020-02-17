import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../service/posts_service.dart';

class LikeButton extends StatelessWidget {
  LikeButton({
    @required this.postId,
  });
  final int postId;

  @override
  Widget build(BuildContext context) {
    //NOTE1: get reactiveModel of PostsService
    final postsServiceRM = Injector.getAsReactive<PostsService>();

    return Row(
      children: <Widget>[
        StateBuilder(
          models: [postsServiceRM],
          builder: (_, __) {
            //NOTE2: Optimizing rebuild. Only Text is rebuild
            return Text('Likes ${postsServiceRM.state.getPostLikes(postId)}');
          },
        ),
        MaterialButton(
          color: Colors.white,
          child: Icon(Icons.thumb_up),
          onPressed: () {
            //NOTE3: incrementLikes is a synchronous method so we do not expect errors
            postsServiceRM.setState((state) => state.incrementLikes(postId));
          },
        )
      ],
    );
  }
}

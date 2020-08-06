import 'package:flutter/material.dart';

import '../../../injected.dart';

class LikeButton extends StatelessWidget {
  LikeButton({
    @required this.postId,
  });
  final int postId;

  @override
  Widget build(BuildContext context) {
    //NOTE1: get reactiveModel of PostsService
    // final postsServiceRM = RM.get<PostsService>();

    return Row(
      children: <Widget>[
        postsService.rebuilder(
          (s) => Text('Likes ${s.getPostLikes(postId)}'),
        ),
        MaterialButton(
          color: Colors.white,
          child: Icon(Icons.thumb_up),
          onPressed: () {
            //NOTE3: incrementLikes is a synchronous method so we do not expect errors
            postsService.setState((state) => state.incrementLikes(postId));
          },
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/comment.dart';
import '../../../injected.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';

class Comments extends StatelessWidget {
  final int postId;
  Comments(this.postId);

  @override
  Widget build(BuildContext context) {
    return commentsInj.listen(
      child: On.all(
        onIdle: () => Container(),
        onWaiting: () => Center(child: CircularProgressIndicator()),
        onError: (_) => Container(),
        onData: () {
          return Expanded(
            child: ListView(
              children: commentsInj.state
                  .map((comment) => CommentItem(comment))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final Comment comment;
  const CommentItem(this.comment);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: commentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            comment.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          UIHelper.verticalSpaceSmall(),
          Text(comment.body),
        ],
      ),
    );
  }
}

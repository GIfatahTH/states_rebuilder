import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/comment.dart';
import '../../../service/comments_service.dart';
import '../../exceptions/error_handler.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';

class Comments extends StatelessWidget {
  final int postId;
  Comments(this.postId);

  @override
  Widget build(BuildContext context) {
    return Injector(
      //NOTE1: Inject CommentsService
      inject: [Inject(() => CommentsService(api: Injector.get()))],
      builder: (context) {
        return StateBuilder<CommentsService>(
          models: [Injector.getAsReactive<CommentsService>()],
          //NOTE2: fetch comments in the init state
          initState: (_, commentsServiceRM) => commentsServiceRM.setState(
            (state) => state.fetchComments(postId),
            //NOTE3: Delegate to ErrorHandler class to show an alert dialog
            onError: ErrorHandler.showErrorDialog,
          ),
          builder: (_, commentsServiceRM) {
            //NOTE4 use whenConnectionState
            return commentsServiceRM.whenConnectionState(
              onIdle: () =>
                  Container(), //Not reachable because setState is called form initState
              onWaiting: () => Center(child: CircularProgressIndicator()),
              onData: (state) => Expanded(
                child: ListView(
                  children: state.comments
                      .map((comment) => CommentItem(comment))
                      .toList(),
                ),
              ),
              //NOTE4: Display empty container on error. An AlertDialog should be displayed
              onError: (_) => Container(),
            );
          },
        );
      },
    );
  }
}

/// Renders a single comment given a comment model
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

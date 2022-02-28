import 'package:clean_architecture_dane_mackier_app/blocs/posts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../blocs/comments_bloc.dart';
import '../../../blocs/user_bloc.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/entities/post.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../exceptions/exception_handler.dart';

//All sub page widgets are part of this top page widget
part 'comment_item.dart';
part 'comments.dart';
part 'comments_injected.dart';
part 'like_button.dart';

class CommentsPage extends StatelessWidget {
  CommentsPage({required this.post});
  final Post post;
  final user = userBloc.user!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            UIHelper.verticalSpaceLarge(),
            Text(post.title, style: headerStyle),
            Text(
              'by ${user.name}',
              style: TextStyle(fontSize: 9.0),
            ),
            UIHelper.verticalSpaceMedium(),
            Text(post.body),
            _LikeButton(
              postId: post.id,
            ),
            _Comments(post.id)
          ],
        ),
      ),
    );
  }
}

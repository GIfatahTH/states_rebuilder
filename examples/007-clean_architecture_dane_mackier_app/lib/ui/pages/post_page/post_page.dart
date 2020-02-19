import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/post.dart';
import '../../../service/authentication_service.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';
import 'comments.dart';
import 'like_button.dart';

class PostPage extends StatelessWidget {
  PostPage({this.post});
  final Post post;
  //NOTE1: Get the logged user
  final user = Injector.get<AuthenticationService>().user;

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
            //NOTE2: Display user name
            Text(
              'by ${user.name}',
              style: TextStyle(fontSize: 9.0),
            ),
            UIHelper.verticalSpaceMedium(),
            Text(post.body),
            //NOTE3: like button widget (like_button.dart)
            LikeButton(
              postId: post.id,
            ),
            //NOTE3: Comments widget (comments.dart)
            Comments(post.id)
          ],
        ),
      ),
    );
  }
}

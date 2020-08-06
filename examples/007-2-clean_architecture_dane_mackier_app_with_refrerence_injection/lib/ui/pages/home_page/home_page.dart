import 'package:flutter/material.dart';

import '../../../domain/entities/post.dart';
import '../../../injected.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../exceptions/error_handler.dart';
import 'postlist_item.dart';

class HomePage extends StatelessWidget {
  final user = authenticationService.state.user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: postsService.whenRebuilderOr(
        initState: (state) {
          postsService.setState(
            (state) => state.getPostsForUser(user.id),
            onError: ErrorHandler.showErrorDialog,
          );
        },
        onWaiting: () => Center(child: CircularProgressIndicator()),
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelper.verticalSpaceLarge(),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'Welcome ${user.name}',
                  style: headerStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text('Here are all your posts', style: subHeaderStyle),
              ),
              UIHelper.verticalSpaceSmall(),
              Expanded(child: getPostsUi(state.posts)),
            ],
          );
        },
      ),
    );
  }

  Widget getPostsUi(List<Post> posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => PostListItem(
          post: posts[index],
          onTap: () {
            Navigator.pushNamed(context, 'post', arguments: posts[index]);
          },
        ),
      );
}

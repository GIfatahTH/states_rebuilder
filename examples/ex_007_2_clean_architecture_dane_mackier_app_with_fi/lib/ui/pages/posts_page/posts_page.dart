import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/api.dart';
import '../../../domain/entities/post.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../exceptions/exception_handler.dart';
import '../login_page/login_page.dart';

part 'posts_injected.dart';
part 'postlist_item.dart';

class PostsPage extends StatelessWidget {
  final user = userInj.state!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: On.or(
        onWaiting: () => Center(child: CircularProgressIndicator()),
        or: () => Column(
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
            Expanded(child: getPostsUi(postsInj.state)),
          ],
        ),
      ).listenTo(postsInj),
    );
  }

  Widget getPostsUi(List<Post> posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => _PostListItem(
          post: posts[index],
        ),
      );
}

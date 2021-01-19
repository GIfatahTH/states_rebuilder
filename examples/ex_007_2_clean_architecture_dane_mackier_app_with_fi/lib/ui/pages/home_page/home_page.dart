import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/post.dart';
import '../../../injected.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';
import 'postlist_item.dart';

class HomePage extends StatelessWidget {
  final user = userInj.state.first;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: postsInj.listen(
        child: On.or(
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
        ),
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

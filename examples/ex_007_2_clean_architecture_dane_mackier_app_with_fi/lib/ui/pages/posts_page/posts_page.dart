import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../blocs/posts_bloc.dart';
import '../../../blocs/user_bloc.dart';
import '../../../domain/entities/post.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';

part 'post_list_item.dart';

class PostsPage extends ReactiveStatelessWidget {
  final user = userBloc.user!;
  @override
  Widget build(BuildContext context) {
    print('Scaffold');
    return Scaffold(
      backgroundColor: backgroundColor,
      body: postsBloc.postsRM.onOrElse(
        onWaiting: () => Center(child: CircularProgressIndicator()),
        orElse: (_) => Column(
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
            Expanded(child: GetPostsUi()),
          ],
        ),
      ),
    );
  }
}

class GetPostsUi extends ReactiveStatelessWidget {
  const GetPostsUi({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: postsBloc.posts.length,
        itemBuilder: (context, index) => _PostListItem(
          post: postsBloc.posts[index],
        ),
      );
}

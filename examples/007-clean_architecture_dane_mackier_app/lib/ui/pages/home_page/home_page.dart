import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/post.dart';
import '../../../service/authentication_service.dart';
import '../../../service/posts_service.dart';
import '../../exceptions/error_handler.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';
import 'postlist_item.dart';

class HomePage extends StatelessWidget {
  final user = Injector.get<AuthenticationService>().user;
  @override
  Widget build(BuildContext context) {
    return Injector(
        inject: [Inject(() => PostsService(api: Injector.get()))],
        builder: (context) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: WhenRebuilderOr<PostsService>(
              models: [ReactiveModel<PostsService>()],
              initState: (_, postsServiceRM) {
                postsServiceRM.setState(
                  (state) => state.getPostsForUser(user.id),
                  onError: ErrorHandler.showErrorDialog,
                );
              },
              onWaiting: () => Center(child: CircularProgressIndicator()),
              builder: (_, postsService) {
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
                      child: Text('Here are all your posts',
                          style: subHeaderStyle),
                    ),
                    UIHelper.verticalSpaceSmall(),
                    Expanded(child: getPostsUi(postsService.state.posts)),
                  ],
                );
              },
            ),
          );
        });
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

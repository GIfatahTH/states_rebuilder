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
  //NOTE1: In the login page we instantiated the user and navigated to this page.
  //NOTE1: We use Injector.get to access AuthenticationService and get user.
  final user = Injector.get<AuthenticationService>().user;
  @override
  Widget build(BuildContext context) {
    return Injector(
        //NOTE2: Inject PostsService
        inject: [Inject(() => PostsService(api: Injector.get()))],
        builder: (context) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: StateBuilder<PostsService>(
              models: [Injector.getAsReactive<PostsService>()],
              initState: (_, postsServiceRM) {
                //NOTE3: get the list of post from the user id
                postsServiceRM.setState(
                  (state) => state.getPostsForUser(user.id),
                  //NOTE3: Delegate error handling to the ErrorHandler to show an alertDialog
                  onError: ErrorHandler.showErrorDialog,
                );
              },
              builder: (_, postsService) {
                //NOTE4: isIdle is unreachable status, because the setState is called from the initState

                //NOTE4: check if waiting
                if (postsService.isWaiting) {
                  return Center(child: CircularProgressIndicator());
                }

                //NOTE4: hasData and hasError (posts=[] so no problem to display empty posts)
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

  //List of posts
  Widget getPostsUi(List<Post> posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => PostListItem(
          post: posts[index],
          onTap: () {
            //Navigate to poste detail
            Navigator.pushNamed(context, 'post', arguments: posts[index]);
          },
        ),
      );
}

import 'package:clean_architecture_dane_mackier_app/blocs/user_bloc.dart';
import 'package:clean_architecture_dane_mackier_app/data_source/api.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/post.dart';
import 'package:clean_architecture_dane_mackier_app/ui/exceptions/exception_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

@immutable
class PostsBloc {
  final postsRM = RM.injectCRUD(
    () => PostRepository(),
    param: () => userBloc.user?.id,
    readOnInitialization: true,
    sideEffects: SideEffects<List<Post>>.onError(
      (err, refresh) => ExceptionHandler.showErrorDialog(err),
    ),
    // debugPrintWhenNotifiedPreMessage: '',
  );
  List<Post> get posts => postsRM.state;
  int getPostLikes(postId) {
    return posts.firstWhere((post) => post.id == postId).likes;
  }

  void incrementLikes(int postId) {
    postsRM.setState(
      (state) {
        posts.firstWhere((post) => post.id == postId).incrementLikes();
        return null;
      },
    );
  }
}

final postsBloc = PostsBloc();

import 'package:clean_architecture_dane_mackier_app/blocs/posts_bloc.dart';
import 'package:clean_architecture_dane_mackier_app/data_source/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

@immutable
class CommentsBloc {
  final commentsRM = RM.injectCRUD(
    () => CommentRepository(),
    // debugPrintWhenNotifiedPreMessage: '',
  );

  void read(int postId) {
    commentsRM.crud.read(param: (_) => postId);
  }
}

final commentsBloc = CommentsBloc();

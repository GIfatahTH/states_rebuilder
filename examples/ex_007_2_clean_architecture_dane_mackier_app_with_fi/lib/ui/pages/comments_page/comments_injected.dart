part of 'comments_page.dart';

final commentsInj = RM.injectCRUD(
  () => CommentRepository(),
  // debugPrintWhenNotifiedPreMessage: '',
);

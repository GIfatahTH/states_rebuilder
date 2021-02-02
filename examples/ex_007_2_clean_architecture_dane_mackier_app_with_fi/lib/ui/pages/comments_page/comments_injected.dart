part of 'comments_page.dart';

final commentsInj = RM.injectCRUD(
  () => CommentRepository(),
  // readOnInitialization: true,
  // debugPrintWhenNotifiedPreMessage: '',
);

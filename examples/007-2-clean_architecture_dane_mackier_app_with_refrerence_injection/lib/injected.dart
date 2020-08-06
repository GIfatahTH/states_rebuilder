import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/api.dart';
import 'service/authentication_service.dart';
import 'service/comments_service.dart';
import 'service/posts_service.dart';

final _api = RM.inject(
  () => Api(),
);

final authenticationService = RM.inject(
  () => AuthenticationService(api: _api.state),
);

final postsService = RM.inject(
  () => PostsService(api: _api.state),
);

final commentsService = RM.inject(
  () => CommentsService(api: _api.state),
);

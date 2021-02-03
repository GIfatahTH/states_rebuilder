class NetworkErrorException implements Exception {
  final message = 'A NetWork problem';
}

class UserNotFoundException implements Exception {
  UserNotFoundException(this._userID);
  final int _userID;
  String get message => 'No user find with this number $_userID';
}

class PostNotFoundException implements Exception {
  PostNotFoundException(this._userID);
  final int _userID;
  String get message => 'No post fount of user with id:  $_userID';
}

class CommentNotFoundException implements Exception {
  CommentNotFoundException(this._postID);
  final int _postID;
  String get message => 'No comment fount of post with id:  $_postID';
}

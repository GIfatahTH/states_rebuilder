class NetworkErrorException extends Error {
  final message = 'A NetWork problem';
}

class UserNotFoundException extends Error {
  UserNotFoundException(this._userID);
  final int _userID;
  String get message => 'No user find with this number $_userID';
}

class PostNotFoundException extends Error {
  PostNotFoundException(this._userID);
  final int _userID;
  String get message => 'No post fount of user with id:  $_userID';
}

class CommentNotFoundException extends Error {
  CommentNotFoundException(this._postID);
  final int _postID;
  String get message => 'No comment fount of post with id:  $_postID';
}

import 'dart:convert';

import '../blocs/exceptions/input_exception.dart';
import 'package:http/http.dart' as http;

import '../domain/entities/comment.dart';
import '../domain/entities/post.dart';
import '../domain/entities/user.dart';
import '../blocs/exceptions/fetch_exception.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

part 'user_repository.dart';
part 'posts_repository.dart';
part 'comments_repository.dart';

const _endpoint = 'https://jsonplaceholder.typicode.com';
final _client = new http.Client();

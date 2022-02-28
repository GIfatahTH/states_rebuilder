import 'package:flutter_movie_example/data_source/movie_repository.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final movieRepositoryRM = RM.inject(() => MovieRepository());

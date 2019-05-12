import 'dart:collection';

import '../api/tmdb_api.dart';
import '../models/movie_genre.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

// ApplicationBloc (on top of everything), responsible for delivering the list of all movie genres;
class BloCMain extends StatesRebuilder {
  BloCMain() {
    // Read all genres from Internet
    api.movieGenres().then((list) {
      outMovieGenres = UnmodifiableListView<MovieGenre>(list.genres);
    });
  }
  List<MovieGenre> outMovieGenres = [];
}

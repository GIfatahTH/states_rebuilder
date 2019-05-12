import 'dart:collection';

// import './bloc_movie_catalogue.dart';
import '../models/movie_card.dart';
// import './bloc_movie_catalogue.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

export 'bloc_setting.dart';

enum favoriteState {
  movieDetailsWidget,
  favoritesPage,
}

// FavoriteBloc (just underneath), responsible for handling the notion of “Favorites”;
class BloCFavorite extends StatesRebuilder {
  ///
  /// Unique list of all favorite movies
  ///
  final Set<MovieCard> _favorites = Set<MovieCard>();

  ///
  /// Interface that allows to add a new favorite movie
  ///

  inAddFavorite(MovieCard movieCard, [state]) {
    // Add the movie to the list of favorite ones

    _favorites.add(movieCard);

    _notify();
    rebuildStates([state]);
  }

  inRemoveFavorite(MovieCard movieCard, [state]) {
    _favorites.remove(movieCard);
    _notify();

    rebuildStates([state]);
  }

  bool outIsFavorite(MovieCard movieCard) {
    return _inFavorites.contains(movieCard);
  }

  int _inTotalFavorites = 0;
  int get outTotalFavorites => _inTotalFavorites;

  List<MovieCard> _inFavorites = [];
  List<MovieCard> get outFavorites => _inFavorites;

  void _notify() {
    // Send to whomever is interested...
    // The total number of favorites
    _inTotalFavorites = _favorites.length;

    // The new list of all favorite movies
    _inFavorites = UnmodifiableListView(_favorites);

    rebuildStates(
      [
        favoriteState.movieDetailsWidget,
        favoriteState.favoritesPage,
        "favoriteButton",
      ],
    );
  }
}

// BloCFavorite bloCFavorite;

import 'package:flutter/material.dart';

import '../blocs/bloc_movie_catalogue.dart';
import '../blocs/bloc_favorite.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../models/movie_card.dart';
import './details.dart';
import './filters.dart';
import '../widgets/favorite_button.dart';
import '../widgets/filters_summary.dart';
import '../widgets/movie_card_widget.dart';

/// ListPage: page that lists the movies as a GridView, allows filtering,
/// favorites selection, access to the Favorites and display of the Movie details in a sub-sequent page;
class ListPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final favoriteBloc = BlocProvider.of<BloCFavorite>(context);
    final movieBloc = BlocProvider.of<BloCMovieCatalogue>(context);

    return StateBuilder(
      stateID: movieCatState.listPage,
      blocs: [movieBloc],
      builder: (_) => Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('List Page'),
              actions: <Widget>[
                // Icon that gives direct access to the favorites
                // Also displays "real-time", the number of favorites
                FavoriteButton(child: const Icon(Icons.favorite)),
                // Icon to open the filters
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    _scaffoldKey.currentState.openEndDrawer();
                  },
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FiltersSummary(),
                Expanded(
                  // Display an infinite GridView with the list of all movies in the catalog,
                  // that meet the filters
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return _buildMovieCard(
                          context, index, movieBloc, favoriteBloc);
                    },
                    itemCount: (movieBloc.outMoviesList == null
                            ? 0
                            : movieBloc.outMoviesList.length) +
                        30,
                  ),
                ),
              ],
            ),
            endDrawer: FiltersPage(),
          ),
    );
  }

  Widget _buildMovieCard(BuildContext context, int index,
      BloCMovieCatalogue movieBloc, BloCFavorite favoriteBloc) {
    // Notify the MovieCatalogBloc that we are rendering the MovieCard[index]
    movieBloc.inMovieIndex(index);
    // Get the MovieCard data
    final MovieCard movieCard = (movieBloc.outMoviesList != null &&
            movieBloc.outMoviesList.length > index)
        ? movieBloc.outMoviesList[index]
        : null;

    if (movieCard == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return MovieCardWidget(
        key: Key('movie_${movieCard.id}'),
        movieCard: movieCard,
        // favoritesStream: favoriteBloc.outFavorites,
        onPressed: (_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return DetailsPage(
                  data: movieCard,
                );
              },
            ),
          );
        });
  }
}

import 'package:flutter/material.dart';
import '../api/tmdb_api.dart';
import '../blocs/bloc_favorite.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../models/movie_card.dart';

///MovieDetailsWidget: widget responsible for displaying the details related to a particular movie and to allow its selection/unselection as a favorite.
class MovieDetailsWidget extends StatelessWidget {
  MovieDetailsWidget({
    Key key,
    this.movieCard,
    this.movieCardState,
    this.boxFit: BoxFit.cover,
  }) : super(key: key);

  final MovieCard movieCard;
  final State movieCardState;
  final BoxFit boxFit;

  @override
  Widget build(BuildContext context) {
    final BloCFavorite bloc = BlocProvider.of<BloCFavorite>(context);

    return StateBuilder(
      stateID: favoriteState.movieDetailsWidget,
      blocs: [bloc],
      builder: (_) => SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Hero(
                        child: Image.network(
                          api.imageBaseUrl + movieCard.posterPath,
                          fit: boxFit,
                        ),
                        tag: 'movie_${movieCard.hashCode}',
                      ),
                      Positioned(
                        top: 16.0,
                        right: 16.0,
                        child: InkWell(
                          onTap: () {
                            if (bloc.outIsFavorite(movieCard)) {
                              bloc.inRemoveFavorite(movieCard, movieCardState);
                            } else {
                              bloc.inAddFavorite(movieCard, movieCardState);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              bloc.outIsFavorite(movieCard)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: bloc.outIsFavorite(movieCard)
                                  ? Colors.red
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.0),
                Text('Vote average: ${movieCard.voteAverage}',
                    style: TextStyle(
                      fontSize: 12.0,
                    )),
                SizedBox(height: 4.0),
                Divider(),
                Container(
                  padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0),
                  child: Text(movieCard.overview),
                ),
              ],
            ),
          ),
    );
  }
}

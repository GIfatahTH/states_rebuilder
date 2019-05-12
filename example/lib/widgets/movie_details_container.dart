import 'package:flutter/material.dart';
import '../blocs/bloc_movie_catalogue.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../widgets/movie_details_widget.dart';

class MovieDetailsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final movieBloc = BlocProvider.of<BloCMovieCatalogue>(context);

    return StateBuilder(
      stateID: movieCatState.movieDetailsContainer,
      blocs: [movieBloc],
      builder: (_) => (movieBloc.containerMovieCard == null)
          ? Center(
              child: Text('Click on a movie to see the details...'),
            )
          : MovieDetailsWidget(
              movieCard: movieBloc.containerMovieCard,
              movieCardState: movieBloc.movieCardState,
              boxFit: BoxFit.contain,
            ),
    );
  }
}

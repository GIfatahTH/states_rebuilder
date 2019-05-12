import 'package:flutter/material.dart';
import '../api/tmdb_api.dart';
import '../blocs/bloc_favorite.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../models/movie_card.dart';

///MovieCardWidget: widget responsible for displaying one single movie as a card,
///with the movie poster, rating and name, as well as a icon to indicate the selection of that particular movie as a favorite;
class MovieCardWidget extends StatelessWidget {
  MovieCardWidget({
    Key key,
    @required this.movieCard,
    @required this.onPressed,
    this.noHero: false,
  }) : super(key: key);

  final MovieCard movieCard;
  final Function onPressed;

  final bool noHero;

  @override
  Widget build(BuildContext context) {
    final BloCFavorite bloc = BlocProvider.of<BloCFavorite>(context);

    return StateBuilder(
      // stateName: id,
      builder: (state) => InkWell(
            onTap: () => onPressed(state),
            child: Card(
              child: Stack(
                fit: StackFit.expand,
                children: getChildren(bloc, state),
              ),
            ),
          ),
    );
  }

  List<Widget> getChildren(BloCFavorite bloc, State state) {
    List<Widget> children = <Widget>[
      ClipRect(
        clipper: _SquareClipper(),
        child: noHero
            ? Image.network(api.imageBaseUrl + movieCard.posterPath,
                fit: BoxFit.cover)
            : Hero(
                child: Image.network(api.imageBaseUrl + movieCard.posterPath,
                    fit: BoxFit.cover),
                tag: 'movie_${movieCard.hashCode}',
              ),
      ),
      Container(
        decoration: _buildGradientBackground(),
        padding: const EdgeInsets.only(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
        ),
        child: _buildTextualInfo(movieCard),
      ),
    ];

    children.add(
      (bloc.outIsFavorite(movieCard) == true)
          ? Positioned(
              top: 0.0,
              right: 0.0,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onTap: () {
                      bloc.inRemoveFavorite(movieCard, state);
                    },
                  )),
            )
          : Container(),
    );
    return children;
  }

  BoxDecoration _buildGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        stops: <double>[0.0, 0.7, 0.7],
        colors: <Color>[
          Colors.black,
          Colors.transparent,
          Colors.transparent,
        ],
      ),
    );
  }

  Widget _buildTextualInfo(MovieCard movieCard) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          movieCard.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          movieCard.voteAverage.toString(),
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _SquareClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return false;
  }
}

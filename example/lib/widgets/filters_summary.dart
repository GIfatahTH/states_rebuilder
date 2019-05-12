import 'package:flutter/material.dart';

import '../blocs/bloc_movie_catalogue.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

///FiltersSummary: widget responsible for displaying the filters currently defined;
class FiltersSummary extends StatelessWidget {
  FiltersSummary({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
//    final MovieGenre genre = ApplicationProvider.of(context).genres.firstWhere((g) => g.genre == data.genre);

    final BloCMovieCatalogue movieBloc =
        BlocProvider.of<BloCMovieCatalogue>(context);
    return Container(
      width: double.infinity,
      height: 40.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text('Genre: ${movieBloc.outGenre}'),
          (movieBloc.outReleaseDate != null)
              ? Text(
                  'Years: [${movieBloc.outReleaseDate[0]} - ${movieBloc.outReleaseDate[1]}]')
              : Container(),
          Text('Total: ${movieBloc.outTotalMovies}'),
        ],
      ),
    );
  }
}

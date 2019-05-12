import 'package:flutter/material.dart';

import '../api/tmdb_api.dart';

import '../blocs/bloc_favorite.dart';
import '../blocs/bloc_provider.dart';
import '../models/movie_card.dart';

///FavoriteWidget: widget responsible for displaying the details of one favorite movie and allow its unselection;
class FavoriteWidget extends StatelessWidget {
  FavoriteWidget({
    Key key,
    this.data,
  }) : super(key: key);

  final MovieCard data;

  @override
  Widget build(BuildContext context) {
    final BloCFavorite bloc = BlocProvider1.of<BloCFavorite>(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: Colors.black54,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 100.0,
          height: 100.0,
          child: Image.network(api.imageBaseUrl + data.posterPath,
              fit: BoxFit.contain),
        ),
        title: Text(data.title),
        subtitle: Text(data.overview, style: TextStyle(fontSize: 10.0)),
        trailing: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.red,
          ),
          onPressed: () {
            bloc.inRemoveFavorite(data);
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/movie_card.dart';
import '../widgets/movie_details_widget.dart';

///Details: page only invoked by ListPage to show the details of a movie but also to allow the selection/unselection of the movie as a favorite;
class DetailsPage extends StatelessWidget {
  DetailsPage({
    Key key,
    this.data,
  }) : super(key: key);

  final MovieCard data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.title),
      ),
      body: MovieDetailsWidget(
        movieCard: data,
      ),
    );
  }
}

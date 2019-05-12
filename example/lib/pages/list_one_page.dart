// import 'package:flutter/material.dart';
// import '../blocs/bloc_movie_catalogue.dart';
// import '../blocs/bloc_favorite.dart';
// import '../blocs/bloc_provider.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';
// import '../models/movie_card.dart';
// import './filters.dart';
// import '../widgets/favorite_button.dart';
// import '../widgets/filters_summary.dart';
// import '../widgets/movie_card_widget.dart';
// import '../widgets/movie_details_container.dart';

// ///ListOnePage: similar to ListPage but the list of movies is displayed as a horizontal list and the details, underneath;
// class ListOnePage extends StatelessWidget {
//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     final favoriteBloc = BlocProvider.of<BloCFavorite>(context);
//     final movieBloc = BlocProvider.of<BloCMovieCatalogue>(context);

//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: Text('List One Page'),
//         actions: <Widget>[
//           // Icon that gives direct access to the favorites
//           // It also displays "real-time" the number of favorites
//           FavoriteButton(
//             child: const Icon(Icons.favorite),
//           ),
//           // Icon to open the filters
//           IconButton(
//             icon: const Icon(Icons.more_horiz),
//             onPressed: () {
//               _scaffoldKey.currentState.openEndDrawer();
//             },
//           ),
//         ],
//       ),
//       body: StateBuilder(
//         stateID: movieCatState.listOnePage,
//         blocs: [movieBloc],
//         builder: (_) => Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 // Displays the filters currently being defined
//                 FiltersSummary(),
//                 Container(
//                   height: 150.0,
//                   // Horizontal list of all movies in the catalog
//                   // based on the filters
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemBuilder: (BuildContext context, int index) {
//                       return _buildMovieCard(index, movieBloc, favoriteBloc);
//                     },
//                     itemCount: (movieBloc.outMoviesList == null
//                             ? 0
//                             : movieBloc.outMoviesList.length) +
//                         30,
//                   ),
//                 ),
//                 Divider(),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     // Container to show the details related to a movie,
//                     // selected by the user
//                     child: MovieDetailsContainer(
//                         // key: _movieDetailsKey,
//                         ),
//                   ),
//                 ),
//               ],
//             ),
//       ),
//       endDrawer: FiltersPage(),
//     );
//   }

//   Widget _buildMovieCard(
//       int index, BloCMovieCatalogue movieBloc, BloCFavorite favoriteBloc) {
//     // Notify the MovieCatalogBloc that we are rendering the MovieCard[index]
//     movieBloc.inMovieIndex(index);
//     // Get the MovieCard data
//     final MovieCard movieCard = (movieBloc.outMoviesList != null &&
//             movieBloc.outMoviesList.length > index)
//         ? movieBloc.outMoviesList[index]
//         : null;

//     // If the movie card is not yet available, display a progress indicator
//     if (movieCard == null) {
//       return Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     // Otherwise, display the movie card
//     return SizedBox(
//       width: 150.0,
//       child: MovieCardWidget(
//         key: Key('movie_${movieCard.id}'),
//         movieCard: movieCard,
//         noHero: true,
//         onPressed: (state) {
//           movieBloc.displayDetailsContainer(movieCard, state);
//         },
//       ),
//     );
//   }
// }

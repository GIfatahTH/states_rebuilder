// import 'package:flutter/material.dart';
// // import 'package:flutter_range_slider/flutter_range_slider.dart';
// import '../blocs/bloc_main.dart';
// import '../blocs/bloc_movie_catalogue.dart';
// import '../blocs/bloc_provider.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';
// import '../models/movie_filters.dart';
// import '../models/movie_genre.dart';

// typedef FiltersPageCallback(MovieFilters result);

// ///Filters: EndDrawer that allows the definition of filters: genres and min/max release dates. This page is called from ListPage or ListOnePage;
// class FiltersPage extends StatelessWidget {
//   FiltersPage({
//     Key key,
//   }) : super(key: key);

//   // bool _isInit = false;

//   @override
//   Widget build(BuildContext context) {
//     final BloCMovieCatalogue _movieBloc =
//         BlocProvider.of<BloCMovieCatalogue>(context);
//     final BloCMain bloCMain = BlocProvider.of<BloCMain>(context);
//     return StateBuilder(
//       stateID: movieCatState.filtersPage,
//       blocs: [_movieBloc],
//       builder: (_) => Scaffold(
//             appBar: AppBar(
//               leading: Container(),
//               title: Text('Filters'),
//               actions: <Widget>[
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//             body: Padding(
//               padding: const EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 10.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   // Release dates range selector

//                   Text(
//                     'Years:',
//                     style: TextStyle(decoration: TextDecoration.underline),
//                   ),
//                   new Container(
//                     width: double.infinity,
//                     child: new Row(
//                       children: <Widget>[
//                         new Container(
//                           constraints: new BoxConstraints(
//                             minWidth: 40.0,
//                             maxWidth: 40.0,
//                           ),
//                           child: new Text('${_movieBloc.minReleaseDate}'),
//                         ),
//                         new Expanded(
//                           child: new SliderTheme(
//                             // Customization of the SliderTheme
//                             // based on individual definitions
//                             // (see rangeSliders in _RangeSliderSampleState)
//                             data: SliderTheme.of(context).copyWith(
//                               activeTrackColor: const Color(0xFFFF0000),
//                               showValueIndicator: ShowValueIndicator.always,
//                             ),
//                             child: Container(),
//                           ),
//                         ),
//                         new Container(
//                           constraints: new BoxConstraints(
//                             minWidth: 40.0,
//                             maxWidth: 40.0,
//                           ),
//                           child: new Text('${_movieBloc.maxReleaseDate}'),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Divider(),

//                   // Genre Selector

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: <Widget>[
//                       Text('Genre:'),
//                       SizedBox(width: 24.0),
//                       new DropdownButton<MovieGenre>(
//                           items: bloCMain.outMovieGenres
//                               .map((MovieGenre movieGenre) {
//                             return DropdownMenuItem<MovieGenre>(
//                               value: movieGenre,
//                               child: new Text(movieGenre.text),
//                             );
//                           }).toList(),
//                           value: _movieBloc.movieGenre,
//                           onChanged: (MovieGenre newMovieGenre) {
//                             _movieBloc
//                                 .dropdownButtonChangeHandler(newMovieGenre);
//                             //           _movieGenre = newMovieGenre;
//                             //           setState(() {});
//                           }),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Filters acceptance

//             floatingActionButton: FloatingActionButton(
//               child: const Icon(Icons.check),
//               onPressed: () {
//                 //
//                 // When the user accepts the changes to the filters,
//                 // we need to send the new filters to the MovieCatalogBloc filters sink.
//                 //
//                 _movieBloc.inFilters();

//                 // close the screen
//                 Navigator.of(context).pop();
//               },
//             ),
//           ),
//     );
//   }

//   ///
//   /// Very tricky.
//   ///
//   /// As we want to be 100% BLoC compliant, we need to retrieve
//   /// everything from the BLoCs, using Streams...
//   ///
//   /// This is ugly but to be considered as a study case.
//   ///
//   // void _getFilterParameters() {
//   //   // StreamSubscription subscriptionMovieGenres;
//   //   // StreamSubscription subscriptionFilters;

//   //   // subscriptionMovieGenres = _appBloc.outMovieGenres.listen((List<MovieGenre> data){
//   //   //   _genres = data;

//   //   //   subscriptionFilters = _movieBloc.outFilters.listen((MovieFilters filters) {
//   //   //     _minReleaseDate = filters.minReleaseDate.toDouble();
//   //   //     _maxReleaseDate = filters.maxReleaseDate.toDouble();
//   //   //     _movieGenre = _genres.firstWhere((g) => g.genre == filters.genre);

//   //   //     // Simply to make sure the subscriptions are released
//   //   //     subscriptionMovieGenres.cancel();
//   //   //     subscriptionFilters.cancel();

//   //   //     // Now that we have all parameters, we may build the actual page
//   //   //     if (mounted){
//   //   //       setState((){
//   //   //         _isInit = true;
//   //   //       });
//   //   //     }
//   //   //   });
//   //   // });

//   //   // Send a request to get the list of the movie genres via stream
//   //   // _appBloc.getMovieGenres(null);
//   // }
// }

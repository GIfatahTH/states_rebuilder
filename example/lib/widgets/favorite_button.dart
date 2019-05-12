// import 'package:flutter/material.dart';
// import '../blocs/bloc_movie_catalogue.dart';
// import '../blocs/bloc_favorite.dart';
// import '../blocs/bloc_provider.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';
// import '../pages/favorites.dart';

// ///FavoriteButton: widget responsible for displaying the number of favorites, real-time, and redirecting to the FavoritesPage when pressed
// class FavoriteButton extends StatelessWidget {
//   FavoriteButton({
//     Key key,
//     @required this.child,
//   }) : super(key: key);

//   final Widget child;

//   // FavoriteButtonState() {
//   //   movieBloc?.favoriteButtonState = this;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final bloc = BlocProvider.of<BloCFavorite>(context);
//     final movieBloc = BlocProvider.of<BloCMovieCatalogue>(context);

//     return StateBuilder(
//         stateID: "favoriteButton",
//         blocs: [bloc, movieBloc],
//         builder: (_) => RaisedButton(
//               onPressed: () {
//                 Navigator.of(context)
//                     .push(MaterialPageRoute(builder: (BuildContext context) {
//                   return FavoritesPage();
//                 }));
//               },
//               child: Stack(
//                 overflow: Overflow.visible,
//                 children: [
//                   child,
//                   Positioned(
//                     top: -12.0,
//                     right: -6.0,
//                     child: Material(
//                       type: MaterialType.circle,
//                       elevation: 2.0,
//                       color: Colors.red,
//                       child: Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Text(
//                             bloc.outTotalFavorites.toString(),
//                             style: TextStyle(
//                               fontSize: 13.0,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )),
//                     ),
//                   ),
//                 ],
//               ),
//             ));
//   }
// }

// import 'package:flutter/material.dart';
// import '../blocs/bloc_movie_catalogue.dart';
// import '../blocs/bloc_provider.dart';

// import './list.dart';
// import './list_one_page.dart';
// import '../widgets/favorite_button.dart';

// // import '../blocs/bloc_favorite.dart';

// /// HomePage: landing page that allows the navigation to the 3 sub-pages;
// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('My Movies')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             RaisedButton(
//               child: Text('Movies List'),
//               onPressed: () {
//                 _openPage(context);
//               },
//             ),
//             FavoriteButton(
//               child: Text('Favorite Movies'),
//             ),
//             RaisedButton(
//               child: Text('One Page'),
//               onPressed: () {
//                 _openOnePage(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openPage(BuildContext context) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (BuildContext context) {
//           return BlocProvider<BloCMovieCatalogue>(
//             bloc: BloCMovieCatalogue(),
//             child: ListPage(),
//           );
//         },
//       ),
//     );
//   }

//   void _openOnePage(BuildContext context) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (BuildContext context) {
//           return BlocProvider<BloCMovieCatalogue>(
//             bloc: BloCMovieCatalogue(),
//             child: ListOnePage(),
//           );
//         },
//       ),
//     );
//   }
// }

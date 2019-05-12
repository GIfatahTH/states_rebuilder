// import 'dart:collection';

// import '../api/tmdb_api.dart';
// import '../models/movie_card.dart';
// import '../models/movie_filters.dart';
// import '../models/movie_genre.dart';
// import '../models/movie_page_result.dart';

// import 'package:states_rebuilder/states_rebuilder.dart';

// enum movieCatState {
//   listPage,
//   favoriteButton,
//   listOnePage,
//   filtersPage,
//   movieDetailsContainer
// }

// // MovieCatalogBloc (on top of the 2 main pages), responsible for delivering the list of movies, based on filters
// class BloCMovieCatalogue extends StatesRebuilder {
//   ///
//   /// Max number of movies per fetched page
//   ///
//   final int _moviesPerPage = 20;

//   ///
//   /// Genre
//   ///
//   int genre = 28;

//   ///
//   /// Release date min
//   ///
//   int minReleaseDate = 2000;

//   ///
//   /// Release date max
//   ///
//   int maxReleaseDate = 2005;

//   ///
//   /// Total number of movies in the catalog
//   ///
//   int _totalMovies = -1;

//   ///
//   /// List of all the movie pages that have been fetched from Internet.
//   /// We use a [Map] to store them, so that we can identify the pageIndex
//   /// more easily.
//   ///
//   final _fetchPages = <int, MoviePageResult>{};

//   ///
//   /// List of the pages, currently being fetched from Internet
//   ///
//   final _pagesBeingFetched = Set<int>();

//   ///
//   /// We are going to need the list of movies to be displayed
//   ///
//   set _outMoviesList(List<MovieCard> v) {
//     outMoviesList = v;
//     rebuildStates(ids: [
//       movieCatState.listPage,
//       "favoriteButton",
//       movieCatState.listOnePage,
//     ]);
//   }

//   List<MovieCard> outMoviesList;

//   ///
//   /// Each time we need to render a MovieCard, we will pass its [index]
//   /// so that, we will be able to check whether it has already been fetched
//   /// If not, we will automatically fetch the page
//   ///
//   inMovieIndex(int index) {
//     final int pageIndex = 1 + ((index + 1) ~/ _moviesPerPage);
//     // check if the page has already been fetched
//     if (!_fetchPages.containsKey(pageIndex)) {
//       // the page has NOT yet been fetched, so we need to
//       // fetch it from Internet
//       // (except if we are already currently fetching it)
//       if (!_pagesBeingFetched.contains(pageIndex)) {
//         // Remember that we are fetching it
//         _pagesBeingFetched.add(pageIndex);
//         // Fetch it
//         api
//             .pagedList(
//                 pageIndex: pageIndex,
//                 genre: genre,
//                 minYear: minReleaseDate,
//                 maxYear: maxReleaseDate)
//             .then(
//               (MoviePageResult fetchedPage) =>
//                   _handleFetchedPage(fetchedPage, pageIndex),
//             );
//       }
//     }
//   }

//   ///
//   /// Once a page has been fetched from Internet, we need to
//   /// 1) record it
//   /// 2) notify everyone who might be interested in knowing it
//   ///
//   void _handleFetchedPage(MoviePageResult page, int pageIndex) {
//     // Remember the page
//     _fetchPages[pageIndex] = page;
//     // Remove it from the ones being fetched
//     _pagesBeingFetched.remove(pageIndex);

//     // Notify anyone interested in getting access to the content
//     // of all pages... however, we need to only return the pages
//     // which respect the sequence (since MovieCard are in sequence)
//     // therefore, we need to iterate through the pages that are
//     // actually fetched and stop if there is a gap.
//     List<MovieCard> movies = <MovieCard>[];
//     List<int> pageIndexes = _fetchPages.keys.toList();
//     pageIndexes.sort((a, b) => a.compareTo(b));

//     final int minPageIndex = pageIndexes[0];
//     final int maxPageIndex = pageIndexes[pageIndexes.length - 1];

//     // If the first page being fetched does not correspond to the first one, skip
//     // and as soon as it will become available, it will be time to notify
//     if (minPageIndex == 1) {
//       for (int i = 1; i <= maxPageIndex; i++) {
//         if (!_fetchPages.containsKey(i)) {
//           // As soon as there is a hole, stop
//           break;
//         }
//         // Add the list of fetched movies to the list
//         movies.addAll(_fetchPages[i].movies);
//       }
//     }

//     // Take the opportunity to remember the number of movies
//     // and notify who might be interested in knowing it
//     if (_totalMovies == -1) {
//       _totalMovies = page.totalResults;
//       _inTotalMovies(_totalMovies);
//     }

//     // Only notify when there are movies
//     if (movies.length > 0) {
//       _outMoviesList = UnmodifiableListView<MovieCard>(movies);
//     }
//   }

//   ///
//   /// Let's put to the limits of the automation...
//   /// Let's consider listeners interested in knowing if a modification
//   /// has been applied to the filters and total of movies, fetched so far
//   ///

//   _inTotalMovies(int total) => outTotalMovies = total;
//   int outTotalMovies = 0;
//   _inReleaseDates(List<int> releaseDate) => outReleaseDate = releaseDate;
//   List<int> outReleaseDate;
//   _inGenre(String genre) => outGenre = genre;
//   String outGenre = "Action";

//   MovieFilters outFilters;
//   MovieGenre movieGenre;

//   ///
//   /// We also want to handle changes to the filters
//   ///
//   inFilters() {
//     // Then, we need to reset
//     _totalMovies = -1;
//     _fetchPages.clear();
//     _pagesBeingFetched.clear();

//     // Let's notify who needs to know
//     _inGenre(movieGenre?.text);
//     _inReleaseDates(<int>[minReleaseDate, maxReleaseDate]);
//     _inTotalMovies(0);

//     // we need to tell about a change so that we pick another list of movies
//     _outMoviesList = [];
//   }

//   silderChangeHandler(int lower, int upper) {
//     minReleaseDate = lower;
//     maxReleaseDate = upper;
//     rebuildStates(ids: [movieCatState.filtersPage]);
//   }

//   dropdownButtonChangeHandler(MovieGenre newMovieGenre) {
//     movieGenre = newMovieGenre;
//     genre = newMovieGenre.genre;
//     rebuildStates(ids: [movieCatState.filtersPage]);
//   }

//   MovieCard containerMovieCard;
//   var movieCardState;
//   displayDetailsContainer(MovieCard movieCard, state) {
//     containerMovieCard = movieCard;
//     movieCardState = state;
//     rebuildStates(ids: [movieCatState.movieDetailsContainer]);
//   }
// }

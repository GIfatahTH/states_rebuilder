import '../models/video_result.dart';

class MovieRepository {
  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<List<VideoResult>> getMovies() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return movies;
  }

  Future<List<VideoResult>> getTvShows() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return tvShows;
  }

  Future<List<VideoResult>> getPopularMovies() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return popularMovies;
  }

  Future<List<VideoResult>> getPopularTvShows() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return popularTVShow;
  }
}

final movies = List.generate(
  20,
  (i) => VideoResult(id: '$i', title: 'Movie $i'),
);

final popularMovies = List.generate(
  3,
  (i) => VideoResult(id: '$i', title: 'MOVIE 1$i'),
);

final tvShows = List.generate(
  20,
  (i) => VideoResult(id: '$i', title: 'Tv show $i'),
);

final popularTVShow = List.generate(
  3,
  (i) => VideoResult(id: '$i', title: 'TV SHOW 1$i'),
);

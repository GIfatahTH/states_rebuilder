import 'package:flutter/cupertino.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../bloc/movie_repository_bloc.dart';
import '../../models/video_result.dart';

@immutable
class HomePageBloc {
  late final _isReadyRM = RM.injectFuture<bool>(
    () async {
      await movieRepositoryRM.state.init();
      return true;
    },
    initialState: false,
  );
  bool get isReady => _isReadyRM.state;

  //

  final _moviesRM = RM.injectFuture<List<VideoResult>>(
    () async => await movieRepositoryRM.state.getMovies(),
    autoDisposeWhenNotUsed: false,
  );
  final _popularMoviesRM = RM.injectFuture<List<VideoResult>>(
    () async => await movieRepositoryRM.state.getPopularMovies(),
    autoDisposeWhenNotUsed: false,
  );

  final _tvShowsRM = RM.injectFuture<List<VideoResult>>(
    () async => await movieRepositoryRM.state.getTvShows(),
    autoDisposeWhenNotUsed: false,
  );
  final _popularTvShowsRM = RM.injectFuture<List<VideoResult>>(
    () async => await movieRepositoryRM.state.getPopularTvShows(),
    autoDisposeWhenNotUsed: false,
  );

  late final _shouldShowMoviesRM = true.inj();
  bool get shouldShowMovies => _shouldShowMoviesRM.state;
  set shouldShowMovies(bool val) => _shouldShowMoviesRM.state = val;
  bool get showVideoResultShimmers =>
      shouldShowMovies ? _moviesRM.isWaiting : _tvShowsRM.isWaiting;
  bool get showPopularVideoResultShimmers {
    return shouldShowMovies
        ? _popularMoviesRM.isWaiting
        : _popularTvShowsRM.isWaiting;
  }

  List<VideoResult> get videoResult =>
      shouldShowMovies ? _moviesRM.state : _tvShowsRM.state;
  List<VideoResult> get popularVideoResult =>
      shouldShowMovies ? _popularMoviesRM.state : _popularTvShowsRM.state;

  void dispose() {
    // Injected state that are not auto disposed are disposed manually
    _moviesRM.dispose();
    _popularMoviesRM.dispose();
    _tvShowsRM.dispose();
    _popularTvShowsRM.dispose();
  }
}

final homePageBloc = HomePageBloc();

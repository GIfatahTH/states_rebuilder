import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../models/video_result.dart';
import 'home_page_bloc.dart';
import 'movie_card.dart';
import 'movie_shimmer.dart';
import 'popular_movie_card.dart';
import 'popular_movie_shimmer.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  List<VideoResult> get videoResult => homePageBloc.videoResult;
  List<VideoResult> get popularVideoResult => homePageBloc.popularVideoResult;
  ButtonStyle? get movieStyle => homePageBloc.shouldShowMovies
      ? ElevatedButton.styleFrom(
          primary: Colors.blue,
          onPrimary: Colors.white,
        )
      : ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.blue,
        );
  ButtonStyle? get tvStyle => homePageBloc.shouldShowMovies
      ? ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.blue,
        )
      : ElevatedButton.styleFrom(
          primary: Colors.blue,
          onPrimary: Colors.white,
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: OnReactive(() {
        return Container(
          padding: const EdgeInsets.all(8),
          child: !homePageBloc.isReady
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              homePageBloc.shouldShowMovies = true;
                            },
                            style: movieStyle,
                            child: const Text('Movies'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              homePageBloc.shouldShowMovies = false;
                            },
                            style: tvStyle,
                            child: const Text('Tv shows'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: homePageBloc.showVideoResultShimmers
                            ? 5
                            : videoResult.length,
                        itemBuilder: (context, index) {
                          if (homePageBloc.showVideoResultShimmers) {
                            return const MovieShimmer();
                          }
                          return MovieCard(index: index);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      homePageBloc.shouldShowMovies
                          ? 'Popular Movies'
                          : 'Popular Tv Shows',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: homePageBloc.showPopularVideoResultShimmers
                          ? const PopularVideoShimmer()
                          : const PopularMovieGrid(),
                    )
                  ],
                ),
        );
      }),
    );
  }
}

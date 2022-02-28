import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../models/video_result.dart';
import 'home_page_bloc.dart';

class PopularMovieGrid extends ReactiveStatelessWidget {
  const PopularMovieGrid({
    Key? key,
  }) : super(key: key);
  List<VideoResult> get popularVideoResult => homePageBloc.popularVideoResult;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4),
            color: Colors.red,
            height: double.infinity,
            child: Center(
              child: Text(
                popularVideoResult[0].title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  color: Colors.green,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      popularVideoResult[1].title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  color: Colors.pink,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      popularVideoResult[2].title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

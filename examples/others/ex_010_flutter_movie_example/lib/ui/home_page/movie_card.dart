import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../models/video_result.dart';
import 'home_page_bloc.dart';

class MovieCard extends ReactiveStatelessWidget {
  const MovieCard({
    Key? key,
    required this.index,
  }) : super(key: key);

  List<VideoResult> get videoResult => homePageBloc.videoResult;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      color: Colors.green,
      width: 120,
      height: double.infinity,
      child: Center(
        child: Text(
          videoResult[index].title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

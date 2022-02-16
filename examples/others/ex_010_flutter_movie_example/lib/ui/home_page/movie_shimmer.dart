import 'package:flutter/material.dart';

class MovieShimmer extends StatelessWidget {
  const MovieShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      color: Colors.grey,
      width: 120,
      height: double.infinity,
      child: const Center(child: Text('Waiting..')),
    );
  }
}

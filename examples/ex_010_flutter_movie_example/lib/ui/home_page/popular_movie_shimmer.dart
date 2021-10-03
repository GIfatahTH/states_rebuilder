import 'package:flutter/material.dart';

class PopularVideoShimmer extends StatelessWidget {
  const PopularVideoShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4),
            color: Colors.grey,
            height: double.infinity,
            child: const Center(child: Text('Waiting..')),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  color: Colors.grey,
                  width: double.infinity,
                  child: const Center(child: Text('Waiting..')),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  color: Colors.grey,
                  width: double.infinity,
                  child: const Center(child: Text('Waiting..')),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class RefreshWidget extends StatelessWidget {
  const RefreshWidget({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);
  final Future Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OnBuilder.create(
        builder: (rm) {
          return rm.onOrElse(
            onWaiting: () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Refreshing ..'),
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
            orElse: (_) => IconButton(
              onPressed: () => rm.stateAsync = onPressed(),
              icon: child,
            ),
          );
        },
      ),
    );
  }
}

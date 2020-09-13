import 'package:flutter/material.dart';

class CounterActionButton extends StatelessWidget {
  CounterActionButton({this.iconData, this.onPressed});
  final VoidCallback onPressed;
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28.0,
      backgroundColor: Theme.of(context).primaryColor,
      child: IconButton(
        icon: Icon(iconData, size: 28.0),
        color: Colors.black,
        onPressed: onPressed,
      ),
    );
  }
}

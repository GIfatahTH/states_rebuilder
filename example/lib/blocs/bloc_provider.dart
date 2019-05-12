import 'package:flutter/material.dart';

class _BlocProvider<T> extends InheritedWidget {
  final bloc;
  _BlocProvider({Key key, @required this.bloc, @required Widget child})
      : super(key: key, child: child);

  static T of<T>(BuildContext context) {
    final type = _typeOf<_BlocProvider<T>>();
    _BlocProvider<T> provider = context.inheritFromWidgetOfExactType(type);
    return provider?.bloc;
  }

  static Type _typeOf<T>() => T;

  @override
  bool updateShouldNotify(_) => false;
}

class BlocProvider1<T> extends StatefulWidget {
  final Widget child;
  final T bloc;
  BlocProvider1({@required this.child, @required this.bloc});

  static T of<T>(BuildContext context) => _BlocProvider.of(context);

  @override
  _BlocProvider1State createState() => _BlocProvider1State<T>();
}

class _BlocProvider1State<T> extends State<BlocProvider1> {
  // T bloc;
  _BlocProvider<T> _blocProvider;
  @override
  void initState() {
    super.initState();
    // bloc = widget.bloc;

    _blocProvider = _BlocProvider<T>(
      bloc: widget.bloc,
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _blocProvider;
  }
}

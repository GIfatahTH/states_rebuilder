import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

typedef BlocBuilder<T> = T Function();
typedef BlocDisposer<T> = Function(T);

class BlocProvider<T> extends StatefulWidget {
  BlocProvider({
    Key key,
    @required this.child,
    @required this.blocBuilder,
    this.blocDispose,
  }) : super(key: key);

  final Widget child;
  final BlocBuilder<T> blocBuilder;
  final BlocDisposer<T> blocDispose;

  @override
  BlocProviderState<T> createState() => BlocProviderState<T>();
}

class BlocProviderState<T> extends State<BlocProvider<T>> {
  T bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.blocBuilder();
  }

  T of<T>(BuildContext context) {
    _BlocProviderInherited<T> provider = context
        .getElementForInheritedWidgetOfExactType<_BlocProviderInherited<T>>()
        ?.widget;

    return provider?.bloc;
  }

  @override
  void dispose() {
    if (widget.blocDispose != null) {
      widget.blocDispose(bloc);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new _BlocProviderInherited<T>(
      bloc: bloc,
      child: widget.child,
    );
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  _BlocProviderInherited({
    Key key,
    @required Widget child,
    @required this.bloc,
  });

  final T bloc;

  @override
  bool updateShouldNotify(_BlocProviderInherited oldWidget) => false;
}

void main() {
  testWidgets('description', (tester) async {
    final counter = RM.inject(() => 0);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            RM.inject(() => 5).inherited(builder: (context) {
              print(counter(context).state);
              return Container();
            }),
            RM.inject(() => 10).inherited(builder: (context) {
              print(counter(context).state);
              return Container();
            }),
            Builder(
              builder: (context) {
                print(counter(context)?.state);
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  });
}

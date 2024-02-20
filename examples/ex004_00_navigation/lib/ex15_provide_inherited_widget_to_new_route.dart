import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Using packages that use the BuildContext to find the provided model have limitation
// when navigation to new route. Provided model must be global to be used cross routes.
//
// This example solve the issue.

void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(routes: {
  '/': (data) => const HomePage(),
  '/item': (data) => const ItemDetailsPage(),
});

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.light(useMaterial3: false),
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Provider<MyModel>(
            create: (_) => MyModel(value: index),
            child: const ItemTile(),
          );
        },
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For deep link we have to gard this route
    final model = Provider.of<MyModel>(context);
    return ListTile(
      title: Text('Item: ${model.value}'),
      onTap: () => navigator.to(
        '/item',
        // Uncomment the this builder to see the typical error of new route without
        // InheritedWidget
        builder: (route) => Provider.value(
          value: model,
          child: route,
        ),
      ),
    );
  }
}

class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MyModel>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Item details: ${model.value}')),
    );
  }
}

/*
// The same example written using states_rebuilder
final modelRM = RM.inject<MyModel>(() => throw UnimplementedError());

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return modelRM.inherited(
            stateOverride: () => MyModel(value: index),
            builder: (_) => const ItemTile(),
          );
        },
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = modelRM.of(context);
    return ListTile(
      title: Text('Item: ${model.value}'),
      onTap: () => navigator.to(
        '/item',
        // Uncomment the this builder to see the typical error of new route without
        // InheritedWidget
        builder: (route) => modelRM.reInherited(
          context: context,
          builder: (_) => route,
        ),
      ),
    );
  }
}

class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = modelRM.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Item details: ${model.value}')),
    );
  }
}
*/
class MyModel {
  final int value;
  MyModel({
    required this.value,
  });
}

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(const MyApp());
}

final index = 0.inj();
final animation = RM.injectAnimation(duration: 200.milliseconds);
final icons = [
  Icons.directions_car,
  Icons.directions_transit,
  Icons.directions_bike,
  Icons.directions_boat,
  Icons.directions_bus_filled,
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TabBarNavigator(),
    );
  }
}

class TabBarNavigator extends StatelessWidget {
  const TabBarNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tab bar navigator'),
      ),
      body: OnReactive(
        () => Center(
          child: Icon(icons[index.state]),
        ),
      ),
      bottomNavigationBar: OnReactive(
        () {
          return OnAnimationBuilder(
            listenTo: animation,
            builder: (animate) {
              return Row(
                children: icons
                    .asMap()
                    .map(
                      (i, icon) {
                        return MapEntry(
                          i,
                          OutlinedButton(
                            onPressed: () => index.state = i,
                            child: Transform.scale(
                              scale:
                                  animate(i == index.state ? 1.2 : 0.8, '$i')!,
                              child: Icon(icon),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: animate(
                                  i == index.state ? Colors.blue : null, '$i'),
                              primary: animate(
                                  i != index.state ? Colors.blue : Colors.white,
                                  'primary$i'),
                            ),
                          ),
                        );
                      },
                    )
                    .values
                    .toList(),
                mainAxisAlignment: MainAxisAlignment.center,
              );
            },
          );
        },
      ),
    );
  }
}

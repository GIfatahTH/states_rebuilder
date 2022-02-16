import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final injectedTabPage = RM.injectTabPageView(
  length: 3,
  //Optional
  initialIndex: 0,
  curve: Curves.ease,
  duration: Duration(milliseconds: 300),
  viewportFraction: 1.0,
  keepPage: true,
);

final animation = RM.injectAnimation(duration: 200.milliseconds);
final icons = [
  Icons.directions_car,
  Icons.directions_transit,
  Icons.directions_bike,
  Icons.directions_boat,
  Icons.directions_bus_filled,
];

class TabViewOnly extends StatelessWidget {
  const TabViewOnly({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: OnReactive(
          () => Text(
            'Page ${injectedTabPage.index} is displayed',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size(0, 40),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  injectedTabPage.previousView();
                },
                icon: Icon(Icons.arrow_back_ios_rounded),
              ),
              IconButton(
                onPressed: () {
                  injectedTabPage.nextView();
                },
                icon: Icon(Icons.arrow_forward_ios_rounded),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  if (injectedTabPage.length > 1) injectedTabPage.length--;
                },
                icon: Icon(Icons.cancel),
              ),
              IconButton(
                onPressed: () {
                  if (injectedTabPage.length < icons.length)
                    injectedTabPage.length++;
                  injectedTabPage.animateTo(injectedTabPage.length - 1);
                },
                icon: Icon(Icons.add_circle),
              ),
            ],
          ),
        ),
      ),
      body: OnTabPageViewBuilder(
        listenTo: injectedTabPage,
        builder: (_) => TabBarView(
          controller: injectedTabPage.tabController,
          children: icons
              .getRange(0, injectedTabPage.length)
              .map((icon) => Icon(icon, size: 50))
              .toList(),
        ),
      ),
      bottomNavigationBar: OnTabPageViewBuilder(
        builder: (_) {
          return TabBar(
            controller: injectedTabPage.tabController,
            tabs: icons
                .getRange(0, injectedTabPage.length)
                .map((icon) => Icon(icon, color: Colors.blue))
                .toList(),
          );
        },
      ),
    );
  }
}

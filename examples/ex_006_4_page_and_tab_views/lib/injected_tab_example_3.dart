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

class MixPageAndTabView extends StatelessWidget {
  const MixPageAndTabView({Key? key}) : super(key: key);

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
      body: OnReactive(
        () => PageView.builder(
          controller: injectedTabPage.pageController,
          itemCount: injectedTabPage.length,
          itemBuilder: (_, i) {
            return Icon(
              icons[i],
              size: 50,
            );
          },
        ),
      ),
      bottomNavigationBar: OnTabPageViewBuilder(
        listenTo: injectedTabPage,
        builder: (index) {
          return BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => injectedTabPage.index = i,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            items: icons
                .getRange(0, injectedTabPage.length)
                .map(
                  (icon) => BottomNavigationBarItem(
                    label: '',
                    icon: Icon(icon),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

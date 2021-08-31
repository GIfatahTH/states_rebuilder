//OK
Practically, in any non-trivial application, we have to use at least one scrollable widget. `ScrollController` is used to gain full control over a Scrollable widget.

Similar to `AnimationController` and `TextEditingController`, `ScrollController` has its own dedicated Injected state.

## Creation of the `InjectedScrolling` state
```dart
final scroll = RM.injectScrolling(
  //Optional arguments
  initialScrollOffset: 0.0,
  keepScrollOffset: true,
  endScrollDelay: 300,
  onScrolling: (scroll){
    // 
  }
);
```
* `initialScrollOffset`, `keepScrollOffset` have similar meaning as in Flutter.
* `endScrollDelay` is the time in milliseconds to wait after the user stops scrolling to consider the scroll event as completed (ended).
* `onScrolling` callback is invoked each time the attached `ScrollController` emits a notification.

Inside `onScrolling`, you can catch a lot of handy scrolling events. You can manage 9 events:

```dart
final scroll = RM.injectScrolling(
  onScrolling: (scroll){

    if (scroll.hasReachedMinExtent) {
      print('Scrolling vertical list is in its top position');
    }
    if (scroll.hasReachedMaxExtent) {
      print('Scrolling vertical list is in its bottom position');
    }

      
    if (scroll.hasStartedScrolling) {
      //Called only one time.
      print('User has just start scrolling');
    }
    if (scroll.hasStartedScrollingForward) {
      print('User has just start scrolling in the forward direction');
    } 
    if (scroll.hasStartedScrollingReverse) {
      print('User has just start scrolling in the reverse direction');
    }


    if (scroll.isScrolling) {
      //Called as long as the user is scrolling
      print('User is scrolling the list');
    }
    if (scroll.isScrollingForward) {
      print('User is scrolling the list in the forward direction');
    }
    if (scroll.isScrollingReverse) {
      print('User is scrolling the list in the reverse direction');
    }


    if (scroll.hasEndedScrolling) {
      // After the user stop scrolling and  after waiting for the defined endScrollDelay 
      print('User has stopped scrolling');
    }

  },
 }
);

```
## Attach the InjectedScrolling with a scrollable widget:

```dart
ListView(
    controller: scroll.controller,
    children: <Widget>[],
)
```

In the widget tree, you can listen to the scrolling events and render the appropriate widget using `OnScrollBuilder` widget.

Here, we manage to hide the `FloatingActionButton` while the user is scrolling and show it when the user stops scrolling:

```dart
floatingActionButton: OnScrollBuilder(
  listenTo: scroll,
  builder: (scroll) {
    if (scroll.isScrolling) {
      //While scrolling return an empty container
      return Container();
    }
    return FloatingActionButton(
      onPressed: () {},
    );
  },
),
```
## InjectedScrolling getter and methods:
- scroll.offset : get the current offset,
- scroll.maxScrollExtent: get the max offset of the scrollable list.
- scroll.minScrollExtent: get the min offset of the scrollable list.
- scroll.moveTo(100): method to move the scroll list to the demanded offset.

## InjectedScrolling state:
the state of "InjectedScrolling" contains the fraction of the current "offset" from the "maxScrollExtent". It is always between 0 and 1, where 0 means the start of the scrollable list while 1 is the end of the list.

Setting the state of `InjectedScrolling` will move the list to the corresponding offset percentage:

example:

``` dart
scroll.state = 0.0; // move the list to the start
scroll.state = 0.5; // move the list to the middle
scroll.state = 1.0 // move the list to the end
```

This is an example where we link the scrolling list to a `Slider`. Scrolling through the list will change the position of the `Slider` and changing the value of the` Slider` will scroll through the list.

```dart
   Column(
        children: <Widget>[
          OnScrollBuilder(
            listenTo: scroll,
            builder: (_) {
              return Slider(
                value: scroll.state,
                onChanged: (val) {
                  scroll.state = val;
                },
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll.controller,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return ListTile(title: Text('Item: $index'));
              },
            ),
          ),
        ],
    ),
```

Here is a fully working example inspired from this [repo](https://resocoder.com/2020/01/21/flutter-hooks-hide-fab-animation-100-widget-code-reuse/):

 This example, we combine `InjectedAnimation` with `InjectedScrolling` to hide a `FloatingActionButton` when the user starts scrolling down and show it when the user starts scrolling up.

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
}

final hideFabAnimController = RM.injectAnimation(
  duration: kThemeAnimationDuration,
  initialValue: 1.0,
);

final scroll = RM.injectScrolling(
  onScroll: (scroll) {
    if (scroll.hasStartedScrollingForward) {
      hideFabAnimController.controller!.forward();
    } else if (scroll.hasStartedScrollingReverse) {
      hideFabAnimController.controller!.reverse();
    }
  },
);

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Let's Scroll"),
      ),
      floatingActionButton: OnAnimationBuilder(
        listenTo: hideFabAnimaController,
        builder: (_) => FadeTransition(
          opacity: hideFabAnimController.curvedAnimation,
          child: ScaleTransition(
            scale: hideFabAnimController.curvedAnimation,
            child: FloatingActionButton.extended(
              label: const Text('Useless Floating Action Button'),
              onPressed: () {},
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        controller: scroll.controller,
        children: <Widget>[
          for (int i = 0; i < 5; i++)
            Card(child: FittedBox(child: FlutterLogo())),
        ],
      ),
    );
  }
}
```
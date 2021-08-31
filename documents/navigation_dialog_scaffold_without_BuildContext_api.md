//OK
With `states_rebuilder`, you can perform side effects that require a `BuildContext` without being forced to be in the widget tree.

# Table of Contents <!-- omit in toc --> 
- [**Navigation**](#Navigation)  
- [**Dialogs and Sheets**](#Dialogs-and-Sheets)  
- [**Show bottom sheets, snackBars and drawers that depend on the scaffolding**](#Show-bottom-sheets,-snackBars-and-drawers-that-depend-on-the-scaffolding)  
- [**Page transition animation**](#Protected-routes)  
- [**Nested Routes and dynamic segments**](#Nested-Routes-and-dynamic-segments)  
- [**SubRoute transition animation**](#SubRoute-transition-animation)  
- [**Protected routes**](#Protected-routes)  



In order for states_rebuilder to navigate and display dialogs without a `BuildContext`, we need to set the` navigatorKey` of the` MaterialApp` widget and assign it to` RM.navigate.navigatorKey`.

```dart
MaterialApp(
  //set the navigator key
  navigatorKey: RM.navigate.navigatorKey,
..
)
```

For named navigation it is recommended to use the `onGenerateRoute` of the `MaterialApp` and delegate it to states_rebuilder :

```dart
 final widget_ = MaterialApp(
      navigatorKey: RM.navigate.navigatorKey,
      onGenerateRoute: RM.navigate.onGenerateRoute(
        {
          '/': (_) => HomePage('Home'),
          '/page1': (RouteData routeData) => Route1(routeData.arguments as String),
          '/page2': (data) => RouteWidget(
                  routes: {
                    '/': (_) => NestedPage20(),
                    '/nestedPage21': (_) => NestedPage21(),
                  }
            ),
          '/page3/:userId': (RouteData data) {
            //
            final queryParams = data.queryParams;
            final pathParams = data.pathParams;
            final arguments = data.arguments;
            //If we push the route like this:
            //RM.navigate.toNamed(/page3/10, queryParams: {'postID': '1' }, arguments: 'Arguments'),
            //
            //The URL will look like this:
            //
            ///page3/10?poseID=1
            //we get:
            //data.queryParams == {'postID': '1' };
            //data.pathParams == {'userId': '10' };
            //data.arguments == 'Arguments';
            //
            //OR
            //Inside a child widget of Page3 :
            //
            //context.routeQueryParams;
            //context.routePathParams;
            //context.routeArguments;
            Page3(routeData.queryParams);
          },
        },
        //Optional argument
        unknownRoute: Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('404'),
            ),
          ),
      ),
    );
```
Notice that `RM.navigate.onGenerateRoute` takes the map of routes and returns the onGenerateRoute to be used in the [MaterialApp.onGenerateRoute].

The routes map is of type `<String, Widget Function(Object? arguments)>` where arguments is the [RouteSettings.settings.arguments]

> You can use named routes as in Flutter and it will work except for page transition animation.

## Navigation
 
states_rebuilder follows the naming convention as in Flutter SDK, with one minor change:
* In Flutter `push` becomes `to` in states_rebuilder.
* In Flutter `pop` becomes `back` in states_rebuilder.

1- push a route:
```dart
 RM.navigate.to(NextPage()); //Flutter: push
```
You can specify a name to the route  (e.g., "/settings"). It will be used with `backUntil`, `toAndRemoveUntil`, `toAndRemoveUntil`, and `toNamedAndRemoveUntil`.
```dart
 RM.navigate.to(NextPage(), name: '/routeName');

 // calling backUntil:
RM.navigate.backUntil('/routeName'); //Flutter: popUntil
```

2- push a named route:
```dart
 RM.navigate.toName('route-name'); //Flutter: pushNamed
```
 
 You can add query parameters :

```dart
 RM.navigate.toName('/route-name' , queryParams: { 'id', '1' }); 
 //The url will looks like this: route-name?id=1
```
To get the queryParams you can use the exposed [RouteData]
```dart
 MaterialApp(
      navigatorKey: RM.navigate.navigatorKey,
      onGenerateRoute: RM.navigate.onGenerateRoute(
        {
          '/route-name': (RouteData data) {
            final queryParams = data.queryParams;
            final pathParams = data.pathParams;
            final arguments = data.arguments
            HomePage('Home')
          },
        },
    );
```
To get the queryParams in a child widget of the route use:

```dart
 context.routeQueryParams;
 context.routePathParams;
 context.routeArguments;
```
3- push a route and replace the current one:
```dart
 RM.navigate.toReplacement(NextPage()); //Flutter: pushReplacement
```
It has a `name` argument similar to `to` method.
4- push a route and replace the current one:
```dart
 RM.navigate.toReplacementNamed('route-name'); //Flutter: pushReplacementNamed
```
5- push a route and remove util the route of the given name:
```dart
 RM.navigate.toAndRemoveUntil(NextPage(), 'previous-route-name'); //Flutter: pushAndRemoveUntil
 //
 // if 'route-name' is omitted, all previous routes are removed
 RM.navigate.toAndRemoveUntil(NextPage());  //The route stack contains only NextPage.
```
It has a `name` argument similar to `to` method.

6- push named route and remove util the route of the given name:
```dart
 RM.navigate.toNamedAndRemoveUntil('route-name', 'previous-route-name'); //Flutter: pushNamedAndRemoveUntil
 //
 // if 'route-name' is omitted, all previous routes are removed
 RM.navigate.toNamedAndRemoveUntil(NextPage());//The route stack contains only NextPage.
```
7- pop a route:
```dart
 RM.navigate.back();//Flutter: pop
```

8- pop all routes until we reach a previous route name:
```dart
 RM.navigate.backUntil(''previous-route-name''); //Flutter: popUntil
```
9- pop the current route and push to a named route:
```dart
 RM.navigate.backAndToNamed(''previous-route-name''); //Flutter: popAndPushNamed
```
10- For any other navigation option, you can use the navigatorState exposed by states_rebuilder:
example:
```dart
 RM.navigate.navigatorState.pushNamedAndRemoveUntil<T>(
      'newRouteName',
      (route) => false,
    )
```
## Dialogs and Sheets
Dialogs when displayed are pushed into the route stack. It is for this reason, in states_rebuilder, dialogs are treated as navigation:

In Flutter to show a dialog:
```dart
showDialog<T>(
    context: navigatorState.context,
    builder: (_) => Dialog(),
);
```
In states_rebuilder to show a dialog:

```dart
RM.navigate.toDialog(Dialog());
```
For sure, states_rebuilder is less boilerplate, but it is also more intuitive.
In states_rebuilder we make it clear that we are navigating to the dialog, so to close a dialog, we just pop it from the route stack.

So states_rebuilder follows the naming convention as in Flutter SDK, with the change from `show` in Flutter to` to` in states_rebuilder.

1- Show a material dialog:
```dart
 RM.navigate.toDialog(DialogWidget());//Flutter: showDialog
```

2- Show a cupertino dialog:
```dart
 RM.navigate.toCupertinoDialog(CupertinoDialogWidget());//Flutter: showCupertinoDialog
```

3- Show a cupertino dialog:
```dart
 RM.navigate.toBottomSheet(BottomSheetWidget());//Flutter: showModalBottomSheet
```

4- Show a cupertino dialog:
```dart
 RM.navigate.toCupertinoModalPopup(CupertinoModalPopupWidget());//Flutter: showCupertinoModalPopup
```
5- For all other dialogs, menus, bottom sheets, not mentioned here, you can use is as defined by flutter using `RM.context`:
example:
```dart
 showSearch(
     context: RM.context, 
     delegate: MyDelegate(),
 )
```

## Show bottom sheets, snackBars and drawers that depend on the scaffolding

Some side effects require a BuildContext of a scaffold child widget.

In state_states_rebuilder to be able to display them outside the widget tree without explicitly specifying the BuildContext, we need to tell states_rebuild which BuildContext to use first.

This can be done either:

```dart
     onPressed: (){
      RM.scaffold.context= context;
      RM.scaffold.showBottomSheet(...);
     }
```
Or 

```dart
    onPressed: (){
    modelRM.setState(
      (s)=> doSomeThing(),
      context: context,
      onData: (_,__){
        RM.scaffold.showBottomSheet(...);
      )
    }
  }
```

If you have one of the states_rebuilder widgets that is a child of the `Scaffold`, you no longer need to specify a `BuildContext`. The `BuildContext` of this widget will be used.

Since `SnackBars`, for example, depend on `ScaffoldState` and aren't pushed to the route stack, we don't treat them as navigation like we did with dialogs.

To distinguish them from Dialogs and to emphasize that they need a Scaffold-related `BuildContext`, we use `RM.scaffold` instead of `RM.navigate`.

1- Show a persistent bottom sheet:
```dart
 RM.scaffold.showBottomSheet(BottomSheetWidget());//Flutter: Scaffold.of(context).showBottomSheet
```
2- Show a snackBar:
```dart
 RM.scaffold.showSnackBar(SnackBarWidget());//Flutter: Scaffold.of(context).showSnackBar
```
3- Open a drawer:
```dart
 RM.scaffold.openDrawer();//Flutter: Scaffold.of(context).openDrawer
```

4- Open a end drawer:
```dart
 RM.scaffold.openEndDrawer();//Flutter: Scaffold.of(context).openEndDrawer
```
5- For anything, not mentioned here, you can use the scaffoldState exposed by states_rebuilder.


## Page transition animation

states_rebuilder offers four predefined page transition animations.
* to animate the page from bottom to up, use : (This is the default Flutter animation):

```dart
main(){
  //In the main app and before runApp method:
  RM.navigate.transitionsBuilder = RM.transitions.bottomToUP();

  runApp(MyApp());
}
```
The above code works for widget routing as well as for named routing provided you use the `RM.navigate.onGenerateRoute` for named routes.

In the latter case (named routing), you can use the `transitionBuilder` parameter of `RM.navigate.onGenerateRoute` to set the transition animation.

```dart
 final widget_ = MaterialApp(
      navigatorKey: RM.navigate.navigatorKey,
      onGenerateRoute: RM.navigate.onGenerateRoute(
        {
          '/': (_) => HomePage('Home'),
          'page1': (param) => Route1(param as String),
          'Route2': (param) => Route2(param as int),
        },
        //Optional argument
        transitionsBuilder:  RM.transitions.bottomToUP();//uses the default flutter param
      ),
    );
```

Page transition animation consists of to animation: translation and opacity animations.

You can set the tween, the curve, and the duration of the position and opacity animation:

```dart
RM.navigate.transitionsBuilder = RM.transitions.bottomToUP(
    //Default: Duration(milliseconds: 300)
    duration: Duration(milliseconds: 500), 
    //Default: Tween<Offset>( begin: const Offset(0.0, 0.25), end: Offset.zero)
    positionTween: Tween<Offset>( begin: const Offset(0.0, 1), end: Offset.zero),
    //Default:  Curves.fastOutSlowIn;
    positionCurve : Curves.bounceInOut,
    //Default: Tween<double>(begin: 0.0, end: 1.0)
    opacityTween: Tween<double>(begin: 0.0, end: 1.0),
    //Curves.easeIn
    opacityCurve : Curves.easeOut,
  );
```

There are four predefined and configurable page transition animations:

```dart
RM.transitions.bottomToUP();
RM.transitions.upToBottom();
RM.transitions.leftToRight();
RM.transitions.rightToLeft();
```

If your animation cannot be done with one of the four predefined animations, you can define your own using `transitionsBuilder` or` pageRouteBuilder` for full options

Example of `transitionBuilder`:
```dart
void main(){

    RM.navigate.transitionsBuilder =
      (context, animation, secondaryAnimation, child) {
    final positionTween = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    );
    final opacityTween = Tween<double>(begin: 0.0, end: 1.0);
    final Animation<Offset> _positionAnimation = animation.drive(
      positionTween.chain(
        CurveTween(curve: Curves.fastOutSlowIn),
      ),
    );
    final Animation<double> _opacityAnimation = animation.drive(
      opacityTween.chain(
        CurveTween(curve: Curves.easeIn),
      ),
    );

    return SlideTransition(
      position: _positionAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: child,
      ),
    );
  };

  runApp(MyApp());
}
```

Example of the full option `pageRouteBuilder`:
```dart
 void main(){

     RM.navigate.pageRouteBuilder = (Widget nextPage) => PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 2000),
        reverseTransitionDuration: Duration(milliseconds: 2000),
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final positionTween = Tween<Offset>(
            begin: const Offset(0.25, 0),
            end: Offset.zero,
          );
          final opacityTween = Tween<double>(begin: 0.0, end: 1.0);
          final Animation<Offset> _positionAnimation = animation.drive(
            positionTween.chain(
              CurveTween(curve: Curves.fastOutSlowIn),
            ),
          );
          final Animation<double> _opacityAnimation = animation.drive(
            opacityTween.chain(
              CurveTween(curve: Curves.easeIn),
            ),
          );

          return SlideTransition(
            position: _positionAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: child,
            ),
          );
        },
      );

      runApp(MyApp())
 }
```

## Nested Routes and dynamic segments

you can use nested routes using `RouteWidget` like this:

```dart
return MaterialApp(
    navigatorKey: RM.navigate.navigatorKey,
    onGenerateRoute: RM.navigate.onGenerateRoute({
      '/': (_) => LoginPage(),
      '/posts': (_) => RouteWidget(
            routes: {
              '/:author': (RouteData data) {
                  final queryParams = data.queryParams;
                  final pathParams = data.pathParams;
                  final arguments = data.arguments;

                  //OR
                  //Inside a child widget of AuthorWidget :
                  //
                  //context.routeQueryParams;
                  //context.routePathParams;
                  //context.routeArguments;
                  return  AuthorWidget();

              },
              '/postDetails': (_) => PostDetailsWidget(),
            },
          ),
      '/settings': (_) => SettingsPage(),
    }),
  );
```


In the UI:
```dart
RM.navigate.to('/'); // => renders LoginPage()
RM.navigate.to('/posts'); // => 404 error
RM.navigate.to('/posts/foo'); // =>  renders AuthorWidget(), with pathParams = {'author' : 'foo' }
RM.navigate.to('/posts/postDetails'); // =>  renders PostDetailsWidget(),
//If you are in AuthorWidget you can use relative path (name without the back slash at the beginning)
RM.navigate.to('postDetails'); // =>  renders PostDetailsWidget(),
RM.navigate.to('postDetails', queryParams : {'postId': '1'}); // =>  renders PostDetailsWidget(),
```

`RouteWidget` has `builder` parameters. it allows to insert widgets above the route.


```dart
return MaterialApp(
    navigatorKey: RM.navigate.navigatorKey,
    onGenerateRoute: RM.navigate.onGenerateRoute({
      '/dashboard': (_) => RouteWidget(
          builder: (Widget child) {
            //child is the route output
            //
            //Instead you can set the entry point where router will display
            //using context.routeWidget
            return DashboardPage(child: child);
          } ,
          routes: {
            '/': (_) => OverviewWidget(),
            newUsers: (_) => RouteWidget(
                  builder: (_) => NewUsersWidget(),
                  routes: {
                    '/:id': (_) => UserDetailWidget(),
                  },
                ),
            sales: (_) => SalesWidget(),
          },
        ),
    }),
);
```

## SubRoute transition animation
What is interesting is that if you define the `builder` and set the entry point where the router will display, only that part of the widget tree will be animated during page transition.

You can override the default transition animation for a particular route using transitionsBuilder of the RouteWidget:

```dart
return MaterialApp(
    navigatorKey: RM.navigate.navigatorKey,
    onGenerateRoute: RM.navigate.onGenerateRoute({
      '/dashboard': (_) => RouteWidget(
          builder: (Widget child) {
            return DashboardPage(child: child);
          } ,
          routes: {
            '/': (_) => OverviewWidget(),
            newUsers: (_) => RouteWidget(
                  builder: (_) => NewUsersWidget(),
                  routes: {
                    '/:id': (_) => UserDetailWidget(),
                  },
                  transitionsBuilder: RM.transitions.upToBottom(),
                ),
            sales: (_) => SalesWidget(),
          },
          //The default custom animation.
          transitionsBuilder: RM.transitions.leftToRight(),

        ),
    }),
);
```

## Protected routes
```dart
return MaterialApp(
    navigatorKey: RM.navigate.navigatorKey,
    onGenerateRoute: RM.navigate.onGenerateRoute({
      '/': (_) => Home(),
      '/about': (_)=> About(),
      '/profile': (data) {
          return data.arguments != null ? Profile(data.arguments as User) : Login(),
      }
    }),
  );
```

If you push the profile route with a valid user object the `Profile` page will be rendered, in the opposite case a `Login` page is displayed instead.



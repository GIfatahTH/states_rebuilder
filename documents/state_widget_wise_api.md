//OK
Fetching a list of items from a backend service, parsing each item To a Widget, displaying it, and performing CRUD operations is a common task in the life of a programmer.

Items are of the same `Widget` type and `state` type, so getting the right state of an item will depend on its position in the widget tree; (The `state` is scoped). Speaking of the position in the widget tree, we implicitly refer to `BuildContext` which contains information about the position of a widget in the widget tree. Likewise, getting the state using `BuildContext` is exactly what `InheritedWidget` is designed for.

Imagine we fetched a list of items and got a list of them:

```dart
//fetched list of ItemData
final List<ItemData> items = [itemData1, itemData2, itemData3, ...];
```
Using `ListView`, we can iterate over each item and render it:

```dart
return ListView.builder(
    itemCount: items.length,
    itemBuilder: (BuildContext context, int index) {
      return ItemWidget(items[index]); //We can not use const here. See later for comparison
    }
)
```
We want to access an item's state from any child widget of `ItemWidget` without having to pass it through a chain of constructors. If you have some experience with Flutter, you might know this is the right place to use `InheritedWidget`.

In states_rebuilder, we build on the concept of `InheritedWidget` to get what we call widget aware injected state.

First, we declare a global injected model to represent a single item.

```dart
//Think to this a a global template to be used by items
final itemData = RM.inject<ItemData>(()=> throw UnimplementedError());
//throwing here because items are populated inside the ListView not here
```
In the `ListVew`: 

```dart
return ListView.builder(
    itemCount: items.length,
    itemBuilder: (BuildContext context, int index) {
      //invoke the inherited method on the global itemData
      return itemData.inherited(
          //How the state of an item is obtained from the list of items
          stateOverride : ()=> items[index],
          //The builder method. Notice we can use const here, which is a big performance gain
          builder: (BuildContext context)=>  const ItemWidget()
      )
    }
)
```

To get the injected state, in a child widget of `ItemWidget`, we use :

```dart
//calling the of method on the global itemData will get the right state using InheritedWidget
//The Element owner of the BuildContext will not listen to the injected model
final Injected<ItemData> itemState = itemData.of(context);

//Or 
//calling the of method on the global itemData will get the right state using InheritedWidget
//The Element owner of the BuildContext will be add to listeners of the injected model.
//When the itemState emits a notification, the Element will rebuild
final ItemData itemState = itemData.call(context);
//call can be removed
final ItemData itemState = itemData(context);

```

As you can see, the global `itemData` injected model, is used to inject the model in the widget tree using `inherited` method and at the same time is used to get the state using the `of` method.

The global injected model as more options:

* `itemData` has `onWaiting`, `onError` and `onData` callbacks.
    ```dart
    final Injected<Todo> itemData = RM.inject(
        () => null,
        onSetState: On.all(
            onWaiting: (){
                //Called if at least one item state is waiting
                print('onWaiting');
            }
            onError: (err, refresh) {
                //Called if at least one item state throws an error
                print('error');
            },
            onData: (item)  (){
                //Called if all item items has data and exposed the item state of the item emitting data
                print('onData');
                //The right pace to update the whole item list
            }
        )
    );
    ```
* Refreshing the global `itemData` state, all item state will be refreshed.
  As `ItemWidget` are constructed with `const` modifier, they will not rebuild when their parent widget rebuild.
  In case we want to reinject the item state and rebuild their listeners, we simply call the refresh method on the global `itemData`.
  ```dart
  itemData.refresh();
  //All the states of the elements are recalculated, and those modified, their auditor is notified to rebuild
  ```  

## `InheritedWidget` limitation
As we know `InheritedWidget` cannot cross route boundary, unless it is defined above the `MaterielApp` widget (which s a non practical case).

After navigation, the `BuildContext` connection loses the connection with the `InheritedWidgets` defined in the old route. To overcome this shortcoming, with state_rebuilder, we can reinject the state to the next route:

```dart
RM.navigate.to(
  itemData.reInherited(
     // Pass the current context
     context : context,
     //The builder method, Notice we can use const here, which is a big performance gain
     builder: (BuildContext context)=>  const NewItemDetailedWidget()
  )
)
```

## States_rebuilder as Provider.

You can use states_rebuilder similar to the Provider package as it relies on `InheritedWidget` to rebuild listeners. This can be done without the limitation of provider as in defining two provider with the same type.

Let's define three injected model with the same type

```dart
final counter1 = RM.inject<int>(() => 10);
final counter2 = RM.inject<int>(() => 20);
final counter3 =
    RM.injectFuture<int>(() => Future.delayed(Duration(seconds: 1), () => 30));
```

```dart
class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Nested injection
     return counter1.inherited(
       builder: (context) => counter2.inherited(
         builder: (context) => counter3.inherited(
           builder: (context) => _MyHomePage(),
         ),
       ),
     );
    //OR  Simply
    return [counter1, counter2, counter3].inherited(
      builder: (context) => _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Text('counter1: ${counter1.of(context)}'),
            Text('counter2: ${counter2.of(context)}'),
            if (counter3.of(context) != null)
              Text('counter3: ${counter3.of(context)}')
            else
              CircularProgressIndicator(),
          ],
        ));
  }
}
```
To mutate the state and notify listener, we just use the injected model as we are used to use. For example if we want to increment counter1:

```dart
onPressed(){
    counter1.state++; 
}
```


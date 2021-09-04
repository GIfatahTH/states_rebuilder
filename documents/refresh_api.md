//OK
# Table of Contents <!-- omit in toc --> 
- [Refresh a Future or stream injected state](#Refresh-a-Future-or-stream-injected-state)
- [Refresh with Flutter's RefreshIndicator](#Refresh-with-Flutter's-RefreshIndicator)
- [Refresh a persisted state](#Refresh-a-persisted-state)

Injected state is created when first used be calling its creation function (creator callback).

```dart
final counter = RM.inject(
    ()=> 0, // The creator callback.
)

print(counter.state); // will print 0
```
We can force the state to re-call its creator callback and reset itself using the `refresh()` method.

```dart
//increment counter by 1
counter.state++;
print(counter.state); // will print 1

//increment counter by 1
counter.state++;
print(counter.state); // will print 2

//refresh counter
counter.refresh();
//the creator callback is re-invoked and the state is set to 0
print(counter.state); // will print 0
```
## Refresh a Future or stream injected state

If the state is injected using `RM.injectFuture` or `RM.injectStream`, and when calling the `refresh` method, any pending async task or stream subscription is canceled and a new async task is fired.

example of Future:

```dart
final future = RM.injectFuture(
    ()async=> fetchSomeThing(), // The creator callback.
);

//once the state is first initialized, the state status is waiting
print(future.isWaiting);// print true

//If refresh is called while future is waiting, 
//the current future is canceled and a new call 
//of fetchSomeThing is called

future.refresh();

print(future.isWaiting); // print true
//after data is available
print(future.hasData); // print true
```

example of Stream:
```dart
final stream = RM.injectStream(
    ()async=> streamSomeData(), // The creator callback.
);

//Stream starts emitting data

//If refresh is called stream subscription is canceled and a new
//subscription is established

stream.refresh();

//Stream starts emitting data from the new subscription
```

## Refresh with Flutter's RefreshIndicator
`refresh` returns a Future of the state. 

A typical use of `refresh` is to refresh a ListView display.

```dart
List<String> _products = [];
Future<List<String>> _fetchProduct() async {
  await Future.delayed(Duration(seconds: 1));
  return _products..add('Product ${_products.length}');
}

final products = RM.injectFuture(() => _fetchProduct());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => products.refresh(),
      child: OnReactive(
        () => products.onOrElse(
          // show a CircularProgressIndicator for the first fetch of products
          onWaiting:
              !products.isActive ? () => CircularProgressIndicator() : null,
          orElse: (_) {
            return ListView.builder(
              itemCount: products.state.length,
              itemBuilder: (context, index) {
                return Text(products.state[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
```

## Refresh a persisted state
If the state is persisted, calling `refresh` will delete the persisted state and replace it with the newly created one.

Example:
```dart
final future = RM.injectFuture(
    () async=> fetchSomeThing(),
    persist:()=> PersistState(
        key: '__key__',
    );
);
```
On state initialization, the state is first obtained from the local storage. If the stored data is not null, the `fetchSomeThing` is not fired and the state holds the stored data.

To force the state to get data from the `fetchSomeThing`, we just call the `refresh` method.
```dart
future.refresh();
```
Here `fetchSomeThing` is invoked and if it ends with data, the data will be stored in the local storage and the state will hold the new data.
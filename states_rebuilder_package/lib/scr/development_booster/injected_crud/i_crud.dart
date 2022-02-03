part of 'injected_crud.dart';

///Interface to implement to query a rest API or
///database for Create,
///Read, Update, and Delete of Items-Item.
///
///The first generic type is the item type.
///
///the second generic type is for the query parameter
///type
///
///```dart
/// class MyItemsRepository implements ICRUD<Item, Param> {
///   @override
///   ICRUD<void> init()async{
///     //initialize any plugging here
///   }
///
///   @override
///   Future<List<Item>> read(Param? param) async {
///     final items = await http.get('uri/${param.user.id}');
///     //After parsing
///     return items;
///
///     //OR
///     // if(param.queryType=='GetCompletedItems'){
///     //    final items = await http.get('uri/${param.user.id}/completed');
///     //    return items;
///     // }else if(param.queryType == 'GetActiveItems'){
///     //   final items = await http.get('uri/${param.user.id}/active');
///     //    return items;
///     // }
///   }
///   @override
///   Future<Item> create(Item item, Param? param) async {
///     final result = await http.post('uri/${param.user.id}/items');
///     return item.copyWith(id: result['id']);
///   }
///
///   @override
///   Future<dynamic> update(List<Item> items, Param? param) async {
///     //Update items
///     return numberOfUpdatedRows;
///   }
///   @override
///   Future<dynamic> delete(List<Item> items, Param? param) async {
///     //Delete items
///   }
///
///   @override
///   void dispose() {
///     //Cleaning resources
///   }
///
/// // You can add here custom methods to perform other requests to the backend
///
/// }
/// ```
abstract class ICRUD<T, P> {
  ///Initialize any plugging and return the
  ///initialized instance.
  Future<void> init();

  ///Read from rest API or a database and get a list
  ///of items
  ///
  ///The param argument can be used to defined the query
  ///parameter
  Future<List<T>> read(P? param);

  ///Create an Item
  ///
  ///It takes an item to create and returns the added
  ///item that
  ///may be different form the taken item (ex: when the
  ///id is
  ///defined form the database).
  ///
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  Future<T> create(T item, P? param);

  ///Update a list of items
  ///
  ///It takes the list of updated items.
  ///
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  ///
  ///[param] can be also used to distinguish between many
  ///update queries
  Future<dynamic> update(List<T> items, P? param);

  ///Delete a list of items
  ///
  ///It takes the list of deleted items.
  ///
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  ///
  ///[param] can be also used to distinguish between many
  ///delete queries
  Future<dynamic> delete(List<T> items, P? param);

  ///It is called when the injected model is disposed
  ///
  ///This is the right place for cleaning resources.
  void dispose();
}

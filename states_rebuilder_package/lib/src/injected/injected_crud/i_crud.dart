part of 'injected_crud.dart';

///Interface to implement to query a rest API or
///database for Create,
///Read, Update, and Delete of Items-Item.
///
///The first generic type is the item type.
///
///the second generic type is for the query parameter
///type
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

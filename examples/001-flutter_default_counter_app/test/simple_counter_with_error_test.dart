//Can not be tested because the business logic is mixed with the UI logic

// The Random().nextBool() can not be neither expected nor mocked.

/// ```dart
/// floatingActionButton: FloatingActionButton(
///   onPressed: () {
///     //set the value of the counter and notify observer widgets to rebuild.
///     counterRM.setValue(
///       () {
///           if (Random().nextBool()) {
///           throw Exception('A Counter Error');
///         }
///         return counterRM.value + 1;
///       },
///       onError: (context, dynamic error) {
///         showDialog(
///           context: context,
///           builder: (context) {
///             return AlertDialog(
///               content: Text('${error.message}'),
///             );
///           },
///         );
///       },
///       onData: (context, int data) {
///         Scaffold.of(context)
///           ..hideCurrentSnackBar()
///           ..showSnackBar(
///             SnackBar(
///               content: Text('$data'),
///             ),
///           );
///       },
///     );
///   },
/// ```
void main() {}

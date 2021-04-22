import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

///Let's use this fake searchRepository
class SearchRepository {
  //
  Future<List<String>> getUsers(String param) async {
    print('GetUser');
    await Future.delayed(Duration(seconds: 1));
    return _data.where((e) => e.startsWith(param)).toList();
  }

  final _data = [
    'Dorie Nelligan',
    'Janine Pettey',
    'Ji Hadsell',
    'Palmer Deatherage',
    'Dionne Hakala',
    'Lyndon Fabry',
    'Frieda Huneke',
    'Lakeesha Walts',
    'Cherelle Kenyon',
    'Janine Ballin',
  ];
}

//
//Inject the SearchRepository
final searchRepo = RM.inject(() => SearchRepository());

//Inject the query (Here is a String but can be any Class with multiple query parameters)
final Injected<String> query = RM.inject(
  () => '',
  //onData is called when the query is changed successfully.
  //fetchedData is refresh which means :
  // - any pending future will be canceled.
  // - a new search request is called
  onData: (_) => fetchedUsers.refresh(),
  debugPrintWhenNotifiedPreMessage: 'query',
);

//Inject the list of fetched user
final fetchedUsers = RM.injectFuture(
  () => searchRepo.state.getUsers(query.state),
  debugPrintWhenNotifiedPreMessage: 'fetchedUsers',
);

//The UI

class UserSearcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: On.data(
        () {
          return query.state.isEmpty
              ? Text('Please enter a user name!')
              : On.or(
                  onWaiting: () => CircularProgressIndicator(),
                  or: () {
                    return Column(
                      children: fetchedUsers.state.map((e) => Text(e)).toList(),
                    );
                  },
                ).listenTo(fetchedUsers);
        },
      ).listenTo(query),
    );
  }
}

//This should be the onChanged of a TextFiled
void _onChanged(String value) {
  query.setState(
    (s) => value,
    debounceDelay: 500,
  );
}

//test

void main() {
  // setUp(() {
  //   RM.disposeAll();
  // });
  testWidgets('initial build', (tester) async {
    await tester.pumpWidget(UserSearcher());
    //As query is empty we see 'Please enter a user name!'
    expect(find.text('Please enter a user name!'), findsOneWidget);
  });

  testWidgets('Search works', (tester) async {
    await tester.pumpWidget(UserSearcher());

    //Enter the letter 'D'
    _onChanged('D');
    await tester.pump();
    //Nothing is changed we must wait for the delay of debounce
    expect(find.byType(CircularProgressIndicator), findsNothing);
    //After 500 ms
    await tester.pump(Duration(milliseconds: 500));
    //The search started
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //After one second
    await tester.pump(Duration(seconds: 1));
    //We get two user that starts with 'D'
    expect(find.byType(Text), findsNWidgets(2));
    expect(find.text('Dorie Nelligan'), findsOneWidget);
    expect(find.text('Dionne Hakala'), findsOneWidget);
  });

  testWidgets('Search is debounced', (tester) async {
    await tester.pumpWidget(UserSearcher());

    //Search for 'J'
    _onChanged('J');
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    //The delay of debounce
    await tester.pump(Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    //We expect to have three result
    expect(find.byType(Text), findsNWidgets(3));
    expect(find.text('Janine Pettey'), findsOneWidget);
    expect(find.text('Ji Hadsell'), findsOneWidget);
    expect(find.text('Janine Ballin'), findsOneWidget);

    //Search for 'Ja
    _onChanged('Ja');
    //before the end of debounce time
    await tester.pump(Duration(milliseconds: 400));
    //we still have the last three result
    expect(find.byType(Text), findsNWidgets(3));

    //update the search
    _onChanged('Jan');
    await tester.pump(Duration(milliseconds: 400));
    expect(find.byType(Text), findsNWidgets(3));
    //update the search before the end of debounce time
    _onChanged('Jani');
    //After the debounce time the search start
    await tester.pump(Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    //We get two result
    expect(find.byType(Text), findsNWidgets(2));
    expect(find.text('Janine Pettey'), findsOneWidget);
    expect(find.text('Ji Hadsell'), findsNothing);
    expect(find.text('Janine Ballin'), findsOneWidget);
  });
}

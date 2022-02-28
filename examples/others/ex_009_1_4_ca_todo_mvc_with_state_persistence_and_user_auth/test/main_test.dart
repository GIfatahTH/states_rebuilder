import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/blocs/auth_bloc.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/blocs/todos_bloc.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/value_object/token.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/main.dart';

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/common/extensions.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/user.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/pages/home_screen/home_screen.dart';

void main() async {
  final storage = await RM.storageInitializerMock();

  setUp(() {
    authBloc.userRM.injectMock(
      () => User(
        userId: 'user1',
        email: 'user1@mail.com',
        token: Token(
          token: 'token_user1',
          refreshToken: 'refreshToken_user1',
          expiryDate: DateTimeX.current.add(
            Duration(seconds: 10),
          ),
        ),
      ),
    );
    todosBloc.todosRM.injectMock(() => []);
    storage.clear();
  });
  testWidgets('Toggle theme should work', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    //App start with dark model
    expect(isDark.isDarkTheme, true);
    expect(Theme.of(RM.context!).brightness == Brightness.dark, true);

    //tap on the ExtraActionsButton
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    //And tap to toggle light mode
    await tester.tap(find.byKey(Key('__toggleDarkMode__')));
    await tester.pumpAndSettle();
    //
    //And theme is light
    expect(Theme.of(RM.context!).brightness == Brightness.light, true);
    //
    //Tap to toggle theme to dark mode
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleDarkMode__')));
    await tester.pumpAndSettle();
    //
    //And theme is dark
    expect(Theme.of(RM.context!).brightness == Brightness.dark, true);
  });

  testWidgets('Change language should work', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    //App start with english
    expect(MaterialLocalizations.of(RM.context!).alertDialogLabel, 'Alert');

    await tester.tap(find.byType(Languages));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AR'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pumpAndSettle();

    //App is in arabic
    expect(MaterialLocalizations.of(RM.context!).alertDialogLabel, 'تنبيه');
    //
    await tester.tap(find.byType(Languages));
    await tester.pumpAndSettle();
    //tap to use system language
    await tester.tap(find.byKey(Key('__System_language__')));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pumpAndSettle();

    //App is back to system language (english).
    expect(MaterialLocalizations.of(RM.context!).alertDialogLabel, 'Alert');
  });
}

// final _user = User(
//   userId: 'user1',
//   email: 'user1@mail.com',
//   token: Token(
//     token: 'token_user1',
//     expiryDate: DateTimeX.current.add(
//       Duration(seconds: 10),
//     ),
//   ),
// ).toJson();

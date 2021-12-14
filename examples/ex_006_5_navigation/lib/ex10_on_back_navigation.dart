import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => const HomePage(),
    '/signin': (data) => const SignInPage(),
  },
  onNavigateBack: (RouteData data) {
    final fromLocation = data.location;
    if (fromLocation == '/signin' && SignInPage.form.isDirty) {
      RM.navigate.toDialog(
        AlertDialog(
          title: const Text(
            'Form is changed and not submitted yet. Do you want to exit?',
          ),
          actions: [
            TextButton(
              onPressed: () => RM.navigate.back(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => RM.navigate.forceBack(),
              child: const Text('Yes'),
            ),
          ],
        ),
        postponeToNextFrame: true,
      );
      return false;
    }
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redirection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigator.to('/signin'),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  static final form = RM.injectForm();
  static final userName = RM.injectTextEditing(text: 'user1');
  static final password = RM.injectTextEditing();
  static final acceptAgreement = RM.injectFormField(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: OnBuilder(
          listenToMany: [userName, password, acceptAgreement, form],
          builder: () {
            if (form.isDirty) {
              return const Text(
                'Form is modified and not submitted yet. \nYou can not exit without confirmation',
              );
            }
            return const Text('You can exit safely');
          },
        ),
      ),
      body: OnFormBuilder(
        listenTo: form,
        builder: () {
          return Column(
            children: [
              TextField(
                controller: userName.controller,
              ),
              TextField(
                controller: password.controller,
              ),
              OnFormFieldBuilder<bool>(
                listenTo: acceptAgreement,
                builder: (value, onChanged) {
                  return CheckboxListTile(
                    value: value,
                    onChanged: onChanged,
                    title: const Text('Do you accept the license agreements?'),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () => form.submit(() async {}),
                child: const Text('Submit'),
              )
            ],
          );
        },
      ),
    );
  }
}

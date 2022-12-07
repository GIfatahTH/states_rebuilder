import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';


final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => const MyHomePage(),
  },
);

void main() {
  runApp(
    MaterialApp.router(
      routerDelegate: navigator.routerDelegate,
      routeInformationParser: navigator.routeInformationParser,
    ),
  );
}

class MyHomePageViewModel {
  void showDialogWithoutTheNeedOfBuildContext() {
    navigator.toDialog(
      AlertDialog(
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              navigator.back();
            },
            child: const Text('NO'),
          ),
        ],
      ),
    );
  }

  void showBottomSheet() {
    navigator.toBottomSheet(
      ColoredBox(
        color: Colors.amber,
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              navigator.back();
            },
            child: const Text('OK'),
          ),
        ),
      ),
    );
  }

  void showCupertionDialog() {
    navigator.toCupertinoDialog(
      CupertinoAlertDialog(
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              navigator.back();
            },
            child: const Text('NO'),
          ),
        ],
      ),
    );
  }

  void showCupertinoModalPopup() {
    navigator.toCupertinoModalPopup(
      ColoredBox(
        color: Colors.amber,
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              navigator.back();
            },
            child: const Text('OK'),
          ),
        ),
      ),
    );
  }

  void showAboutDialogWithoutBuildContext() {
    showAboutDialog(
      context: NavigationBuilder.context!,
      applicationName: 'Navigation builder',
    );
  }

  // Scaffold related pop ups
  void showPersistentBottomSheet() {
    navigator.scaffold.showBottomSheet(
      BottomSheet(
        onClosing: () {},
        builder: (context) {
          return ColoredBox(
            color: Colors.amber,
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  navigator.back();
                },
                child: const Text('OK'),
              ),
            ),
          );
        },
      ),
    );
  }

  void openDrawer() {
    navigator.scaffold.openDrawer();
  }

  void openEndDrawer() {
    navigator.scaffold.openEndDrawer();
  }

  void showMaterialBanner() {
    navigator.scaffold.showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.amber,
        content: const Text('Material Banner'),
        actions: [
          TextButton(
            onPressed: () => navigator.scaffold.removeCurrentMaterialBanner(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

final myHomePageViewModel = MyHomePageViewModel();

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed:
                    myHomePageViewModel.showDialogWithoutTheNeedOfBuildContext,
                child: const Text('Show Dialog'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: myHomePageViewModel.showBottomSheet,
                child: const Text('Show Bottom sheet'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: myHomePageViewModel.showCupertionDialog,
                child: const Text('Show Cupertino dialog'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: myHomePageViewModel.showCupertinoModalPopup,
                child: const Text('Show Cupertino Modal Popup'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed:
                    myHomePageViewModel.showAboutDialogWithoutBuildContext,
                child: const Text('Show About dialog'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  navigator.scaffold.showSnackBar(
                    SnackBar(
                      content: const Text('HI'),
                      action: SnackBarAction(
                        label: 'Hide',
                        onPressed: () =>
                            navigator.scaffold.hideCurrentSnackBar(),
                      ),
                    ),
                  );
                },
                child: const Text('Show  SnackBar'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  myHomePageViewModel.showMaterialBanner();
                },
                child: const Text('Show  Material banner'),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      navigator.scaffold.context = context;
                      myHomePageViewModel.showPersistentBottomSheet();
                    },
                    child: const Text('Show  bottom sheet'),
                  );
                },
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      navigator.scaffold.context = context;
                      myHomePageViewModel.openDrawer();
                    },
                    child: const Text('Open Drawer'),
                  );
                },
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      navigator.scaffold.context = context;
                      myHomePageViewModel.openEndDrawer();
                    },
                    child: const Text('Open EndDrawer'),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: TextButton(
          onPressed: () => navigator.back(),
          child: const Text('Close Drawer'),
        ),
      ),
      endDrawer: Drawer(
        child: TextButton(
          onPressed: () => navigator.back(),
          child: const Text('Close EndDrawer'),
        ),
      ),
    );
  }
}

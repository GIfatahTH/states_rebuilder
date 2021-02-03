import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

abstract class IConfiguration {
  String appName = '';
  Color primaryColor = Colors.white;
  //
  //more ...
}

//Development implementation
class DevConfiguration implements IConfiguration {
  @override
  String appName = 'Development configuration';

  @override
  Color primaryColor = Colors.red;
}

//Production implementation
class ProdConfiguration implements IConfiguration {
  @override
  String appName = 'Production configuration';

  @override
  Color primaryColor = Colors.blue;
}

//

enum env { DEV, PROD }

//USe injectInterface to register the two implementation
final configuration = RM.injectFlavor({
  env.DEV: () => DevConfiguration(),
  env.PROD: () => ProdConfiguration(),
});

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    configuration.dispose();

    //OR
    //RM.disposeAll();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(configuration.state.appName),
    );
  }
}

void main() {
  //We can use the static method RM.disposeAll() to dispose all injected models
  // setUp(() {
  //   RM.disposeAll();
  // });
  testWidgets('Development Configuration', (tester) async {
    RM.env = env.DEV;
    await tester.pumpWidget(MyApp());

    expect(find.text('Development configuration'), findsOneWidget);
    expect(configuration.state.primaryColor, Colors.red);
  });

  testWidgets('Production Configuration', (tester) async {
    RM.env = env.PROD;
    await tester.pumpWidget(MyApp());

    expect(find.text('Production configuration'), findsOneWidget);
    expect(configuration.state.primaryColor, Colors.blue);
  });
}

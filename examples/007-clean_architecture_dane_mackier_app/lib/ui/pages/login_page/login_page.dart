import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../service/authentication_service.dart';
import '../../exceptions/error_handler.dart';
import '../../common/app_colors.dart';
import '../../widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StateBuilder<AuthenticationService>(
      //NOTE1: getting the registered reactiveModel
      models: [Injector.getAsReactive<AuthenticationService>()],
      //Note2: disposing TextEditingController to free resources.
      dispose: (_, __) => controller.dispose(),
      builder: (context, authServiceRM) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoginHeader(
              //NOTE3: ErrorHandler is a class method used to center error handling.
              //NOTE4: errorMessage returns a string description of the thrown error if there is one.
              //NOTE4: because we are handling error we must catch them is setState method.
              validationMessage: ErrorHandler.errorMessage(authServiceRM.error),
              controller: controller,
            ),
            //NOTE5: if authServiceRM ReactiveModel if it is waiting.
            authServiceRM.isWaiting
                ? CircularProgressIndicator()
                : FlatButton(
                    color: Colors.white,
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      //NOTE6: call setState method
                      authServiceRM.setState(
                        (state) => state.login(controller.text),
                        //NOTE7: catchError
                        // catchError: true,

                        onError: ErrorHandler.showSnackBar,

                        //NOTE8: Check if user is logged (authServiceRM has data) and route to home page
                        onData: (context, authServiceRM) {
                          Navigator.pushNamed(context, '/');
                        },
                      );
                    },
                  )
          ],
        );
      },
    );
  }
}

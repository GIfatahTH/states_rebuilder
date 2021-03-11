part of 'login_page.dart';

class _LoginHeader extends StatelessWidget {
  final TextEditingController controller;

  _LoginHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Login', style: headerStyle),
        UIHelper.verticalSpaceMedium(),
        Text('Enter a number between 1 - 10', style: subHeaderStyle),
        LoginTextField(controller),
        On.or(
          onError: (error, refresh) => Text(
            ExceptionHandler.errorMessage(error),
            style: TextStyle(color: Colors.red),
          ),
          or: () => Container(),
        ).listenTo(userInj),
      ],
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;

  LoginTextField(this.controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      height: 50.0,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
      child: TextField(
          decoration: InputDecoration.collapsed(hintText: 'User Id'),
          controller: controller),
    );
  }
}

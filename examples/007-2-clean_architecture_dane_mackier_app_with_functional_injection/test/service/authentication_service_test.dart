import 'package:clean_architecture_dane_mackier_app/service/authentication_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data_source/fake_api.dart';

void main() {
  test('login', () async {
    final authService = AuthenticationService(api: FakeApi());

    await authService.login('1');

    expect(authService.user.name, equals('Fake User Name'));
  });
}

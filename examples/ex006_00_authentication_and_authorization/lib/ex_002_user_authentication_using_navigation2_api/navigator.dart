import 'package:states_rebuilder/scr/state_management/rm.dart';

import 'blocs/auth_bloc.dart';
import 'ui/home_page/home_page.dart';
import 'ui/sign_in_page/sign_in_page.dart';
import 'ui/sign_in_register_form_page/sign_in_register_form_page.dart';

final navigator = RM.injectNavigator(
  routes: {
    '/': (_) => const HomePage(),
    '/sign_in': (_) => const SignInPage(),
  },
  transitionsBuilder: RM.transitions.leftToRight(),
  onNavigate: (routeData) {
    print(routeData);
    if (routeData.location != '/sign_in' && !authBloc.isUserAuthenticated) {
      return routeData.redirectTo('/sign_in');
    }
    if (routeData.location == '/sign_in' && authBloc.isUserAuthenticated) {
      return routeData.redirectTo('/');
    }
    return null;
  },
);

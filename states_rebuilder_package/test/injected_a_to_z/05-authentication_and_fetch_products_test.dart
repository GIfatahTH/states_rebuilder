import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/* --- Models --*/
//Simple user model
class User {
  final String userId;
  final String token;

  User({this.userId, this.token});
}

//Simple product model
class Product {
  final String id;

  Product({this.id});
}

/* --- Repository --*/
abstract class IAuthRepository {
  Future<User> login(String name, String email);
  Future<void> logout();
}

//The product Repository depends on the authenticate user
abstract class IProductRepository {
  final String userId;
  final String token;

  IProductRepository(this.userId, this.token);

  Future<List<Product>> getProducts();
}

/* --- data source --*/
//Implementation of repositories
class FirebaseAuth implements IAuthRepository {
  @override
  Future<User> login(String name, String password) {
    //Some implementation
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }
}

class FirebaseCloud implements IProductRepository {
  final String token;
  final String userId;
  FirebaseCloud({this.token, this.userId});
  @override
  Future<List<Product>> getProducts() {
    //depending on the userID and on the token the corresponding products will be returned
    throw UnimplementedError();
  }
}

/* --- Service class (Link between UI and data sources) -- */
class AuthService {
  final IAuthRepository _authRepository;

  AuthService(this._authRepository);
  User user;
  Future<User> login({String name, String password}) async {
    user = await _authRepository.login(name, password);
    return user;
  }

  void logout() {
    user = null;
    _authRepository.logout();
  }
}

class ProductService {
  final IProductRepository _productRepository;

  ProductService(this._productRepository);
  List<Product> products;
  Future<List<Product>> getProducts() async {
    products = await _productRepository.getProducts();
    return products;
  }
}

/* --- functional injection --- */
//Inject the FirebaseAuth and register it with IAuthRepository (It will be mocked)
final authRepository = RM.inject<IAuthRepository>(() => FirebaseAuth());
//Inject the authService
final authService = RM.inject(() => AuthService(authRepository.state));
//
//Inject the IProductRepository and register it with FirebaseCloud (It will be mocked)
//As it depends on the authService, we use  injectComputed
final productRepository = RM.injectComputed<IProductRepository>(
  compute: (_) => FirebaseCloud(
    userId: authService.state.user?.userId,
    token: authService.state.user?.token,
  ),
  //re-execute the compute method only if the user changes
  shouldCompute: (productRepository) =>
      productRepository?.userId != authService.state.user?.userId,
);

//Inject Product Service
final productService = RM.inject(() => ProductService(productRepository.state));

/* -- The UI --*/
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return authService.whenRebuilderOr(
      onWaiting: () => Text('Waiting for authentication'),
      builder: () =>
          authService.state.user == null ? AuthPage() : ProductPage(),
    );
  }
}

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Auth Page');
  }
}

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return productService.whenRebuilder(
      //fetch for products once the ProductPage is initialized
      initState: () => productService.setState((s) => s.getProducts()),
      onIdle: () => Text('onIDel'),
      onWaiting: () => Text('Waiting for products'),
      onError: (e) => Text('error : $e'),
      onData: () => Column(
        children: productService.state.products.map((p) => Text(p.id)).toList(),
      ),
    );
  }
}

/* -- Testing --*/
// mocking
class FakeAuthRepository extends IAuthRepository {
  @override
  Future<User> login(String name, String email) async {
    //
    await Future.delayed(Duration(seconds: 1));
    //
    if (name == 'user-1') {
      return User(userId: 'user-1', token: 'token-1');
    }
    if (name == 'user-2') {
      return User(userId: 'user-2', token: 'token-2');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    //logout
  }
}

class FakeProductRepository extends IProductRepository {
  FakeProductRepository({String userId, String token}) : super(userId, token);

  @override
  Future<List<Product>> getProducts() async {
    //
    await Future.delayed(Duration(seconds: 1));
    //
    if (userId == 'user-1') {
      //return one product for user-1
      return [Product(id: 'Product-1-user-1')];
    }
    if (userId == 'user-2') {
      //return two products for user-2
      return [Product(id: 'Product-1-user-2'), Product(id: 'Product-2-user-2')];
    }
    return null;
  }
}

void main() {
  //inject the fake implementations
  authRepository.injectMock(() => FakeAuthRepository());
  productRepository.injectComputedMock(
    compute: (_) => FakeProductRepository(
      userId: authService.state.user?.userId,
      token: authService.state.user?.token,
    ),
  );
  //
  testWidgets('first start, app in the Auth page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MyApp(),
    ));
    //at start up we expect to see the AuthPage
    expect(find.byType(AuthPage), findsOneWidget);
  });

  //
  testWidgets('user filled fields and logged in', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MyApp(),
    ));

    //simulate use entered a name and an password
    void _onPressedLogInUser1() {
      authService.setState(
        (s) => s.login(name: 'user-1', password: 'user1@mail.com'),
      );
    }

    void _onPressedLogInUser2() {
      authService.setState(
        (s) => s.login(name: 'user-2', password: 'user2@mail.com'),
      );
    }

    //simulate user tapped the logout button
    void _onPressedLogout() {
      authService.setState(
        (s) => s.logout(),
      );
    }

    //First scenario: log in with user-1
    //
    //User tapped on the log in button
    _onPressedLogInUser1();

    await tester.pump();
    //Waiting for authentication
    expect(find.text('Waiting for authentication'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    //we are int ProductPage screen
    expect(find.byType(ProductPage), findsOneWidget);
    await tester.pump();
    //the fetch for products in triggered and we are waiting for them
    expect(find.text('Waiting for products'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    //Whe get one product of user-1
    expect(find.text('Product-1-user-1'), findsOneWidget);
    //
    //Second scenario: log out
    _onPressedLogout();
    await tester.pump();
    expect(find.byType(AuthPage), findsOneWidget);
    //
    //Third scenario: log in with user-2
    _onPressedLogInUser2();
    await tester.pump();
    expect(find.text('Waiting for authentication'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.byType(ProductPage), findsOneWidget);
    await tester.pump();
    expect(find.text('Waiting for products'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    //We get Two products for user-2
    expect(find.text('Product-1-user-2'), findsOneWidget);
    expect(find.text('Product-2-user-2'), findsOneWidget);
  });
}

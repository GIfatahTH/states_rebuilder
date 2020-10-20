import 'dart:async';

import 'package:states_rebuilder/states_rebuilder.dart';

import './ui/common/enums.dart';
import 'data_source/firebase_auth_repositoy.dart';
import 'data_source/firebase_todos_repository.dart';
import 'domain/common/extensions.dart';
import 'domain/entities/todo.dart';
import 'domain/entities/user.dart';
import 'domain/value_object/todos_stats.dart';
import 'domain/value_object/token.dart';
import 'service/auth_state.dart';
import 'service/common/enums.dart';
import 'service/interfaces/i_auth_repository.dart';
import 'service/todos_state.dart';
import 'ui/exceptions/error_handler.dart';
import 'ui/pages/auth_page/auth_page.dart';
import 'ui/pages/home_screen/home_screen.dart';

final Injected<List<Todo>> todos = RM.inject(() => [],
    persist: () => PersistState(
          key: '__Todos__/${user.state.userId}',
          toJson: (todos) => todos.toJson(),
          fromJson: (json) => ListTodoX.fromJson(json),
          persistStateProvider: FireBaseTodosRepository(
            authToken: user.state.token.token,
          ),
          // debugPrintOperations: true,
        ),
    onError: (e, s) {
      ErrorHandler.showErrorSnackBar(e);
    }
    // debugPrintWhenNotifiedPreMessage: 'todos',
    );

final activeFilter = RM.inject(() => VisibilityFilter.all);

final Injected<List<Todo>> todosFiltered = RM.injectComputed(
  compute: (_) {
    if (activeFilter.state == VisibilityFilter.active) {
      return todos.state.where((t) => !t.complete).toList();
    }
    if (activeFilter.state == VisibilityFilter.completed) {
      return todos.state.where((t) => t.complete).toList();
    }
    return todos.state;
  },
  // debugPrintWhenNotifiedPreMessage: 'TodosFilter',
);

final Injected<TodosStats> todosStats = RM.injectComputed(
  compute: (_) {
    return TodosStats(
      numCompleted: todos.state.where((t) => t.complete).length,
      numActive: todos.state.where((t) => !t.complete).length,
    );
  },
  // debugPrintWhenNotifiedPreMessage: '',
);

final activeTab = RM.inject(() => AppTab.todos);

final Injected<Todo> todoItem = RM.inject(
  () => null,
  onData: (t) {
    todos.setState(
      (s) => s.updateTodo(t),
    );
  },
);

//

final authRepository = RM.inject<IAuthRepository>(() => FireBaseAuth());

final authService = RM.inject(
  () => AuthService(authRepository: authRepository.state),
);

final user = RM.inject<User>(
  () => UnsignedUser(),
  //As We want the logged use to be available throughout the whole app life cycle,
  //we prevent it from auto disposing the injected model.
  //
  //As for the app, nothing will be affected. The only issue is when testing the app.
  //To allow tests to pass, it is preferable to manually dispose the app when the app is disposed.
  autoDisposeWhenNotUsed: false,
  persist: () => PersistState(
    key: '__UserToken__',
    toJson: (user) => user.toJson(),
    fromJson: (json) {
      final user = User.fromJson(json);
      return user.token?.isAuth == true ? user : null;
    },
    // debugPrintOperations: true,
  ),
  // debugPrintWhenNotifiedPreMessage: '',
  onInitialized: (User u) {
    if (u != null && u is! UnsignedUser) {
      _setExpirationTimer(u.token);
    }
  },
  onData: (User u) {
    if (u is UnsignedUser) {
      _cancelExpirationTimer();
      RM.navigate.toAndRemoveUntil(const AuthPage());
    } else {
      _setExpirationTimer(u.token);
      RM.navigate.toAndRemoveUntil(const HomeScreen());
    }
  },
  onError: (e, s) {
    ErrorHandler.showErrorSnackBar(e);
  },
  onDisposed: (_) {
    _cancelExpirationTimer();
  },
);

Timer _authTimer;
void _setExpirationTimer(Token token) {
  _cancelExpirationTimer();
  final timeToExpiry = token.expiryDate.difference(DateTimeX.current).inSeconds;
  _authTimer = Timer(
    Duration(seconds: timeToExpiry),
    () {
      user.state = authService.state.logout();
    },
  );
}

void _cancelExpirationTimer() {
  if (_authTimer != null) {
    _authTimer.cancel();
    _authTimer = null;
  }
}

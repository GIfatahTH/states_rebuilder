import 'dart:async';

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/data_source/firebase_todos_repository.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/user.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/auth_state.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/interfaces/i_auth_repository.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/sqflite.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/pages/auth_page/auth_page.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/pages/home_screen/home_screen.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import './ui/common/enums.dart';
import 'data_source/firebase_auth_repositoy.dart';
import 'domain/common/extensions.dart';
import 'domain/entities/todo.dart';
import 'domain/value_object/todos_stats.dart';
import 'service/common/enums.dart';
import 'service/todos_state.dart';

import 'ui/exceptions/error_handler.dart';

final Injected<List<Todo>> todos = RM.inject(
  () => [],
  persist: PersistState(
    key: '__Todos__2',
    toJson: (todos) => todos.toJson(),
    fromJson: (json) => ListTodoX.fromJson(json),
    onPersistError: (e, s) async {
      ErrorHandler.showErrorSnackBar(e);
    },
    persistStateProvider: () => FireBaseTodosRepository(
      userId: user.state.userId,
      authToken: user.state.token.token,
    ),
    // debugPrintOperations: true,
  ),
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
  debugPrintWhenNotifiedPreMessage: '',
);

final activeTab = RM.inject(() => AppTab.todos);

final Injected<Todo> injectedTodo = RM.inject(
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
  persist: PersistState(
    key: '__UserToken__',
    toJson: (user) => user.toJson(),
    fromJson: (json) {
      final user = User.fromJson(json);
      return user.token.isAuth ? user : null;
    },
    debugPrintOperations: true,
  ),
  debugPrintWhenNotifiedPreMessage: '',
  onInitialized: (User u) {
    if (u is UnsignedUser) {
      // RM.navigate.toNamed(AuthPage.routeName);
    } else {
      // RM.navigate.toNamedAndRemoveUntil(HomeScreen.routeName);
      if (_authTimer != null) {
        _authTimer.cancel();
      }
      final timeToExpiry =
          u.token.expiryDate.difference(DateTimeX.current).inSeconds;
      _authTimer = Timer(
        Duration(seconds: timeToExpiry),
        () => user.state = authService.state.logout(),
      );
    }
  },
  onData: (User u) {
    if (u is UnsignedUser) {
      RM.navigate.toNamedAndRemoveUntil(AuthPage.routeName);
      if (_authTimer != null) {
        _authTimer.cancel();
        _authTimer = null;
      }
    } else {
      RM.navigate.toNamedAndRemoveUntil(HomeScreen.routeName);
    }
  },
);

Timer _authTimer;

import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/service/interfaces/i_todo_repository.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/auth_repository.dart';
import 'data_source/todo_repository.dart';
import 'service/auth_state.dart';
import 'service/common/enums.dart';
import 'service/interfaces/i_auth_repository.dart';
import 'service/todos_state.dart';
import 'ui/common/enums.dart';

final authRepository = RM.inject<IAuthRepository>(() => AuthRepository());
/*
In test you do not need any external mocking libraries. To test you have :

- Create your fake implementation of IAuthRepository interface.
- Injected the fake implementation :
main(){
  authRepository.injectMock(()=>FakeRepositoryImplementation())

  testWidgets('test1', (tester)async{

  }
 );
}
Now the testing app will use the fake implementation rather then the real implementation.
*/

final authState = RM.inject<AuthState>(
  () => InitAuthState(authRepository.state),
);

final todosRepository = RM.injectComputed<ITodosRepository>(
  compute: (_) => TodosRepository(
    user: authState.state.user,
  ),
);

final todosState = RM.injectComputed<TodosState>(
  compute: (s) => s.copyWith(
    todoRepository: todosRepository.state,
  ),
  initialState: TodosState(
    todos: [],
    activeFilter: VisibilityFilter.all,
    todoRepository: todosRepository.state,
  ),
);

final activeTab = RM.inject(() => AppTab.todos);

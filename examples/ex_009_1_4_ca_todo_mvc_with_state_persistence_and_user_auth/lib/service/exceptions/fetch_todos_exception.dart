import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/common/localization/localization.dart';

class CRUDTodosException implements Exception {
  final String message;
  CRUDTodosException.pageNotFound() : message = i18n.state.pageNotFound;
  CRUDTodosException.netWorkFailure() : message = i18n.state.networkFailure;
  @override
  String toString() {
    return message.toString();
  }
}

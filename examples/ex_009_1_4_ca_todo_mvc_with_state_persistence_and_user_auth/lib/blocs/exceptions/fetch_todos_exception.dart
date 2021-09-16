import '../../ui/localization/localization.dart';

class CRUDTodosException implements Exception {
  final String message;
  CRUDTodosException.pageNotFound() : message = i18n.state.pageNotFound;
  CRUDTodosException.netWorkFailure() : message = i18n.state.networkFailure;
  @override
  String toString() {
    return message.toString();
  }
}

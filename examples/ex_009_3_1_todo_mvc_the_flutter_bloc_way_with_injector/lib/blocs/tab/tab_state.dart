import 'package:equatable/equatable.dart';
import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';

class AppTabState extends Equatable {
  final AppTab appTab;
  const AppTabState([this.appTab = AppTab.todos]);

  @override
  List<Object> get props => [appTab];

  static AppTabState updateAppTab(AppTab tab) {
    return AppTabState(tab);
  }

  @override
  String toString() {
    return '$appTab';
  }
}

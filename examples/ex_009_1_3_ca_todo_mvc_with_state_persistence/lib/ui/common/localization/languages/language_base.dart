import 'dart:ui';

import 'package:states_rebuilder/states_rebuilder.dart';

abstract class I18N {
  static Map<Locale, I18N> _supportedLanguage = {
    Locale.fromSubtags(languageCode: 'en'): EN_US(),
  };

  static List<Locale> get supportedLocale => _supportedLanguage.keys.toList();

  static I18N getLanguages(Locale locale) =>
      _supportedLanguage[locale] ?? EN_US();

  String get appTitle => 'States_rebuilder Example';
  String todos = 'Todos';

  String stats = 'Stats';

  String showAll = 'Show All';

  String showActive = 'Show Active';

  String showCompleted = 'Show Completed';

  String newTodoHint = 'What needs to be done?';

  String markAllComplete = 'Mark all complete';

  String markAllIncomplete = 'Mark all incomplete';

  String clearCompleted = 'Clear completed';

  String addTodo = 'Add Todo';

  String editTodo = 'Edit Todo';

  String saveChanges = 'Save changes';

  String filterTodos = 'Filter Todos';

  String deleteTodo = 'Delete Todo';

  String todoDetails = 'Todo Details';

  String emptyTodoError = 'Please enter some text';

  String notesHint = 'Additional Notes...';

  String completedTodos = 'Completed Todos';

  String activeTodos = 'Active Todos';

  String todoDeleted(String task) => 'Deleted "$task"';

  String undo = 'Undo';

  String deleteTodoConfirmation = 'Delete this todo?';

  String delete = 'Delete';

  String cancel = 'Cancel';

  String switchToDarkMode = 'switch to dark mode';
  String switchToLightMode = 'switch to light mode';
}

class EN_US extends I18N {}

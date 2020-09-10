// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:todo_mvc_the_flutter_bloc_way/blocs/todos/todos.dart';
import 'package:todo_mvc_the_flutter_bloc_way/injected.dart';
import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';

abstract class FilteredTodosState extends Equatable {
  const FilteredTodosState();
  @override
  List<Object> get props => [];
}

class FilteredTodosLoading extends FilteredTodosState {
  const FilteredTodosLoading();
}

class FilteredTodosLoaded extends FilteredTodosState {
  final List<Todo> filteredTodos;
  final VisibilityFilter activeFilter;

  const FilteredTodosLoaded(
    this.filteredTodos,
    this.activeFilter,
  );
  //Here we use static method.
  //We can use instance method as in StatsLoaded.
  ///_mapUpdateFilterToState
  static Stream<FilteredTodosState> updateFilter(
    FilteredTodosLoaded currentState,
    VisibilityFilter filter,
  ) async* {
    if (todosState.state is TodosLoaded) {
      yield currentState.copyWith(
        filteredTodos: _mapTodosToFilteredTodos(
          (todosState.state as TodosLoaded).todos,
          filter,
        ),
        activeFilter: filter,
      );
    }
  }

  ///_mapTodosUpdatedToState
  static FilteredTodosLoaded updateTodos(
    FilteredTodosState currentState,
    List<Todo> todos,
  ) {
    if (currentState is FilteredTodosLoaded) {
      return currentState.copyWith(
        filteredTodos: _mapTodosToFilteredTodos(
          todos,
          currentState.activeFilter,
        ),
        activeFilter: currentState.activeFilter,
      );
    } else {
      return FilteredTodosLoaded(
        todos,
        VisibilityFilter.all,
      );
    }
  }

  static List<Todo> _mapTodosToFilteredTodos(
    List<Todo> todos,
    VisibilityFilter filter,
  ) {
    return todos.where((todo) {
      if (filter == VisibilityFilter.all) {
        return true;
      } else if (filter == VisibilityFilter.active) {
        return !todo.complete;
      } else {
        return todo.complete;
      }
    }).toList();
  }

  FilteredTodosLoaded copyWith({
    List<Todo> filteredTodos,
    VisibilityFilter activeFilter,
  }) {
    return FilteredTodosLoaded(
      filteredTodos ?? this.filteredTodos,
      activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object> get props => [filteredTodos, activeFilter];

  @override
  String toString() {
    return 'FilteredTodosLoaded { filteredTodos: $filteredTodos, activeFilter: $activeFilter }';
  }
}

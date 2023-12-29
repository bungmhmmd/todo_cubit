// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:todo_cubit/cubits/todo_filter/todo_filter_cubit.dart';
import 'package:todo_cubit/cubits/todo_list/todo_list_cubit.dart';
import 'package:todo_cubit/cubits/todo_search/todo_search_cubit.dart';
import 'package:todo_cubit/models/todo_model.dart';

part 'filtered_todos_state.dart';

class FilteredTodosCubit extends Cubit<FilteredTodosState> {
  late StreamSubscription todoListSubscription;
  late StreamSubscription todoFilterSubscription;
  late StreamSubscription todoSearchSubscription;

  final TodoListCubit todoListCubit;
  final TodoFilterCubit todoFilterCubit;
  final TodoSearchCubit todoSearchCubit;

  final List<TodoModel> initialTodos;
  FilteredTodosCubit({
    required this.initialTodos,
    required this.todoListCubit,
    required this.todoFilterCubit,
    required this.todoSearchCubit,
  }) : super(FilteredTodosState(filteredTodos: initialTodos)) {
    todoListSubscription =
        todoListCubit.stream.listen((TodoListState todoList) {
      setFilteredTodos();
    });

    todoFilterSubscription =
        todoFilterCubit.stream.listen((TodoFilterState todoFilterState) {
      setFilteredTodos();
    });

    todoSearchSubscription =
        todoSearchCubit.stream.listen((TodoSearchState todoSearchState) {
      setFilteredTodos();
    });
  }

  void setFilteredTodos() {
    List<TodoModel> _filteredTodos;

    switch (todoFilterCubit.state.filter) {
      case Filter.all:
        _filteredTodos = todoListCubit.state.todos;
        break;
      case Filter.active:
        _filteredTodos = todoListCubit.state.todos
            .where((TodoModel todo) => !todo.completed)
            .toList();
        break;
      case Filter.completed:
        _filteredTodos = todoListCubit.state.todos
            .where((TodoModel todo) => todo.completed)
            .toList();
        break;
    }

    if (todoSearchCubit.state.searchTerm != '') {
      _filteredTodos = _filteredTodos
          .where((TodoModel todo) => todo.desc
              .toLowerCase()
              .contains(todoSearchCubit.state.searchTerm.toLowerCase()))
          .toList();
    }

    emit(state.copyWith(filteredTodos: _filteredTodos));
  }

  @override
  Future<void> close() {
    todoListSubscription.cancel();
    todoFilterSubscription.cancel();
    todoSearchSubscription.cancel();
    return super.close();
  }
}

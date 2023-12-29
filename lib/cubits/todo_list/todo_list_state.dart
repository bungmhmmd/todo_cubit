part of 'todo_list_cubit.dart';

class TodoListState extends Equatable {
  final List<TodoModel> todos;

  TodoListState({required this.todos});

  factory TodoListState.initial() {
    return TodoListState(todos: [
      TodoModel(id: '1', desc: 'Clean the room'),
      TodoModel(id: '2', desc: 'Wash the dishes'),
      TodoModel(id: '3', desc: 'Do homework'),
    ]);
  }

  @override
  List<Object> get props => [todos];

  TodoListState copyWith({
    List<TodoModel>? todos,
  }) {
    return TodoListState(
      todos: todos ?? this.todos,
    );
  }

  @override
  String toString() {
    return 'TodoListState(todos: $todos)';
  }
}

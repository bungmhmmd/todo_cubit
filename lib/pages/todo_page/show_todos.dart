import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_cubit/cubits/cubits.dart';
import 'package:todo_cubit/cubits/filtered_todos/filtered_todos_cubit.dart';
import 'package:todo_cubit/models/todo_model.dart';

class ShowTodos extends StatelessWidget {
  const ShowTodos({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<FilteredTodosCubit>().state.filteredTodos;
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemCount: todos.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: ValueKey(todos[index].id),
          background: showBackground(0),
          secondaryBackground: showBackground(1),
          onDismissed: (_) {
            context.read<TodoListCubit>().removeTodo(todos[index]);
          },
          confirmDismiss: (_) => showDeleteConfirmationDialog(context),
          child: TodoItem(todo: todos[index]),
        );
      },
    );
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Todo'),
              content:
                  const Text('Are you sure you want to delete this todo item?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  // onPressed: () => Navigator.of(context).pop(false),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget showBackground(int direction) {
    return Container(
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.red,
      alignment: direction == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class TodoItem extends StatefulWidget {
  final TodoModel todo;
  const TodoItem({super.key, required this.todo});

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late TextEditingController todoDescController;

  @override
  void initState() {
    super.initState();
    todoDescController = TextEditingController();
  }

  @override
  void dispose() {
    todoDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              bool _error = false;
              todoDescController.text = widget.todo.desc;

              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return AlertDialog(
                      title: Text('Edit'),
                      content: TextField(
                        controller: todoDescController,
                        autofocus: true,
                        decoration: InputDecoration(
                            hintText: 'Type something',
                            errorText: _error ? 'Can\'t be empty' : null),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Edit'),
                          onPressed: () {
                            if (todoDescController.text.isEmpty) {
                              setState(() {
                                _error = true;
                              });
                            } else {
                              context.read<TodoListCubit>().editTodo(
                                  widget.todo.id, todoDescController.text);
                              Navigator.of(context).pop();
                            }
                          },
                        )
                      ]);
                },
              );
            });
      },
      leading: Checkbox(
        value: widget.todo.completed,
        onChanged: (bool? value) {
          context.read<TodoListCubit>().toggleTodo(widget.todo.id);
        },
      ),
      title: Text(
        widget.todo.desc,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

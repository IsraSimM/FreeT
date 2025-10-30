import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget auxiliar para manejar estados `AsyncValue`.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final WidgetBuilder? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading?.call(context) ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => this.error?.call(error, stackTrace) ??
          Center(child: Text('Se produjo un error: $error')),
    );
  }
}

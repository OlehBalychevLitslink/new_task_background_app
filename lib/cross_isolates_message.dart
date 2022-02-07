import 'dart:isolate';

class CrossIsolatesMessage<T> {
  final SendPort sender;
  final T? message;

  CrossIsolatesMessage({
    required this.sender,
    this.message,
  });
}
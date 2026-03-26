import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';

@Singleton(order: -1)
class ToastManager {
  BuildContext? _context;

  set context(BuildContext context) {
    _context = context;
  }

  BuildContext get context {
    final ctx = _context;
    if (ctx != null && ctx.mounted) return ctx;
    throw Exception('No BuildContext found');
  }

  void show(String message, {String? description, Widget? action}) {
    ShadToaster.of(context).show(
      ShadToast(
        title: Text(message),
        description: description != null ? Text(description) : null,
        action: action,
      ),
    );
  }

  void error(String message, {String? description, Widget? action}) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: Text(message),
        description: description != null ? Text(description) : null,
        action: action,
      ),
    );
  }
}

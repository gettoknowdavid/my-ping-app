import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';

@Singleton(order: -1)
class ToastManager {
  final toasterKey = GlobalKey<ShadToasterState>();

  void show(String message, {String? description, Widget? action}) {
    toasterKey.currentState?.show(
      ShadToast(
        title: Text(message),
        description: description != null ? Text(description) : null,
        action: action,
      ),
    );
  }

  void error(String message, {String? description, Widget? action}) {
    print(message);
    print(description);
    toasterKey.currentState?.show(
      ShadToast.destructive(
        title: Text(message),
        description: description != null ? Text(description) : null,
        action: action,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/managers/toast_manager.dart';

class ToastConnector extends StatefulWidget {
  const ToastConnector({required this.child, super.key});

  final Widget? child;

  @override
  State<ToastConnector> createState() => _ToastConnectorState();
}

class _ToastConnectorState extends State<ToastConnector> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    di<ToastManager>().context = context;
  }

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox.shrink();
}

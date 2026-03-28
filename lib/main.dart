import 'package:flutter/material.dart';
import 'package:ping/_injector/_injector.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/managers/toast_manager.dart';
import 'package:ping/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureCoreDependencies();
  Command.globalExceptionHandler = (error, stacktrace) {
    debugPrint('Command error [${error.commandName}]: ${error.error}');
    di<ToastManager>().error(error.error.toString());
  };
  runApp(const PingApp());
}

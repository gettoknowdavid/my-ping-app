import 'package:flutter/material.dart';
import 'package:ping/_injector/_injector.dart';
import 'package:ping/_ping.dart';
import 'package:ping/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  Command.globalExceptionHandler = (error, stacktrace) {
    debugPrint('Command error [${error.commandName}]: ${error.error}');
    di.toastManager.error(error.error.toString());
  };
  runApp(const MyApp());
}

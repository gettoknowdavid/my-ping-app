import 'package:flutter/material.dart';
import 'package:ping/_injector/injector.dart';
import 'package:ping/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

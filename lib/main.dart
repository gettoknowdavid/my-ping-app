import 'package:flutter/material.dart';
import 'package:ping/app.dart';
import 'package:ping/locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}

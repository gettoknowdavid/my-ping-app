import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/auth/model/_model.dart';

class HomePage extends WatchingWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = di<Profile>();
    log(profile.toString());
    return Scaffold(
      appBar: AppBar(
        leading: ShadAvatar('', placeholder: Text(profile.displayName ?? '')),
      ),
    );
  }
}

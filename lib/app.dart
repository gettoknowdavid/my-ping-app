import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_routing/_routing.dart';
import 'package:ping/_shared/widgets/toast_connector.dart';

class PingApp extends WatchingWidget {
  const PingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final snapshot = watchFuture<GetIt, void>(
      (getIt) => getIt.allReady(timeout: const Duration(seconds: 30)),
      target: di,
      initialValue: null,
    );

    if (snapshot.hasError) {
      final error = snapshot.error;
      return ShadApp(
        title: 'Ping',
        home: Scaffold(
          body: ShadCard(title: Text(error.toString())),
        ),
      );
    }

    if (snapshot.connectionState != ConnectionState.done) {
      return ShadApp(
        title: 'Ping',
        home: Scaffold(
          body: Center(
            child: const Icon(LucideIcons.loaderCircle)
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 1.seconds),
          ),
        ),
      );
    }

    return ShadApp.custom(
      appBuilder: (context) => MaterialApp.router(
        title: 'Ping',
        routerConfig: di<PingRouter>().config,
        builder: (context, child) {
          return ShadAppBuilder(child: ToastConnector(child: child));
        },
      ),
    );
  }
}

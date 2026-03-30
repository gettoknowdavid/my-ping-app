import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';

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
        themeMode: ThemeMode.dark,
        theme: PingTheme.theme,
        darkTheme: PingTheme.darkTheme,
        home: Scaffold(body: ShadCard(title: Text(error.toString()))),
      );
    }

    if (snapshot.connectionState != ConnectionState.done) {
      return ShadApp(
        title: 'Ping',
        themeMode: ThemeMode.dark,
        theme: PingTheme.theme,
        darkTheme: PingTheme.darkTheme,
        home: const Scaffold(body: LoadingIndicator(size: 24)),
      );
    }

    return ShadApp.router(
      title: 'Ping',
      themeMode: ThemeMode.dark,
      theme: PingTheme.theme,
      darkTheme: PingTheme.darkTheme,
      routerConfig: di<PingRouter>().config,
      builder: (context, child) => ShadToaster(
        key: di<ToastManager>().toasterKey,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

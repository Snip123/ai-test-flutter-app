import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'shared/telemetry/telemetry.dart';

void main() {
  // OTel must be initialised before runApp — ADR-0012
  AppTelemetry.init();

  runApp(
    const ProviderScope(
      child: FsiApp(),
    ),
  );
}

class FsiApp extends StatelessWidget {
  const FsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FSI Platform',
      theme: fsiTheme,
      routerConfig: appRouter,
    );
  }
}

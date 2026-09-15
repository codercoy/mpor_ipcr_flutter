import 'package:flutter/material.dart';

import '../features/shell/presentation/app_shell_page.dart';

class MporIpcrApp extends StatelessWidget {
  const MporIpcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MPOR / IPCR System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const AppShellPage(),
    );
  }
}
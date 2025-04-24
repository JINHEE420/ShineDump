import 'package:flutter/material.dart';

class SecondaryApp extends StatelessWidget {
  const SecondaryApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: home,
    );
  }
}

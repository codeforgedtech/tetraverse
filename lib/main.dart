import 'package:Tetrisverse/game/CodeCraftmanSplash.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tetraverse',
      debugShowCheckedModeBanner: false,
      home: CodeCraftmanSplash(), // 👈 Visa meny/startskärm först
    );
  }
}



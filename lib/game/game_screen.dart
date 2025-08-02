import 'package:Tetrisverse/game/gravity.dart';
import 'package:Tetrisverse/game/tetraverse_game.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';



class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2c3e50),
              Color(0xFF8e44ad),
              Color(0xFFe91e63),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GameWidget(
          game: TetraverseGame(GravityManager()),
        ),
      ),
    );
  }
}

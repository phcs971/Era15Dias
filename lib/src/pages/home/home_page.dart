import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildChallenge(String title, int number, String page) {
      return ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(32)),
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return 4;
            } else if (states.contains(MaterialState.hovered)) {
              return 16;
            }
            return 8;
          }),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
        ),
        onPressed: () => Navigator.of(context).pushNamed(page),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 40, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            Text(
              "$number",
              style: const TextStyle(fontSize: 96, color: Colors.black),
            ),
          ],
        ),
      );
    }

    Widget _buildChallenges() {
      return Row(
        children: [
          const Spacer(flex: 2),
          _buildChallenge("Eram só\n15 dias!", 1, "/era15dias"),
          const Spacer(),
          _buildChallenge("Jogo da\nVelha!", 2, "/jogoDaVelha"),
          const Spacer(flex: 2),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEC),
      body: Column(
        children: [
          const Spacer(),
          const Text(
            "QUAL DESAFIO DESEJA ABRIR: ",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 96,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildChallenges(),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

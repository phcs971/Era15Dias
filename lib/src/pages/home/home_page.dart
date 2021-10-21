import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../utils.dart';

const images = [
  'assets/images/stories/gincana_angustia.png',
  'assets/images/stories/gincana_angustia_2.png',
  'assets/images/stories/gincana_covid.png',
  'assets/images/stories/gincana_covid_2.png',
  'assets/images/stories/gincana_covid_3.png',
  'assets/images/stories/gincana_headache.png',
  'assets/images/stories/gincana_morto.png',
  'assets/images/stories/gincana_raiva.png',
  'assets/images/stories/gincana_raiva_2.png',
  'assets/images/stories/gincana_raiva_3.png',
  'assets/images/stories/gincana_raiva_4.png',
  'assets/images/stories/gincana_tristeza.png',
  'assets/images/stories/gincana_tristeza_2.png',
];
final rand = Random();

class Projectile {
  final double dh;
  final double dt;
  final String image;

  double offset = 0.0;

  Projectile()
      : image = images.randomElement()!,
        dh = rand.nextDouble(),
        dt = rand.nextDouble() * 45 * (rand.nextBool() ? 1 : -1);

  double top(double prop) {
    return prop * (180 + 70 * dh);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double offset = 0.0;
  double points = 0.0;
  int ticks = 250;
  bool spaceOn = false, pause = true, start = true;

  bool? result;

  Timer? timer;
  final initialDate = DateTime(2020, 3, 12);
  DateTime get currentDate => initialDate.add(Duration(days: (offset / 700).round()));

  final focus = FocusNode();

  onTimer(Timer t) {
    if (!pause) {
      ticks += 1;
      if (!spaceOn) points += 0.033;
      var k = pow(1.2, pow(ticks, 1 / 2.8));
      for (var p in projectiles) {
        p.offset += k;
      }
      setState(() => offset += k);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt');
    reset();
    timer = Timer.periodic(const Duration(milliseconds: 33), onTimer);
  }

  @override
  void dispose() {
    super.dispose();
    focus.dispose();
    timer?.cancel();
  }

  void togglePause() {
    setState(() {
      pause = !pause;
    });
  }

  void onStart() {
    if (start) {
      start = false;
      Future.delayed(const Duration(seconds: 2)).then((value) {
        projectiles.add(Projectile());
      });
    }
  }

  void reset() {
    offset = 0.0;
    ticks = 250;
    pause = true;
    start = true;
    points = 0.0;
    result = null;
    projectiles = <Projectile>[];
  }

  Future<void> getNewProjectile() async {
    setState(() {
      projectiles = [];
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      projectiles.add(Projectile());
    });
  }

  Future<void> endGame() async {
    setState(() {
      result = false;
      pause = true;
    });
  }

  var projectiles = <Projectile>[];

  @override
  Widget build(BuildContext context) {
    Widget _buildImage(String image, double multiplier) {
      final off = offset * multiplier;
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 33),
        top: 0,
        bottom: 0,
        width: MediaQuery.of(context).size.width * 2 + off,
        left: -off,
        child: Image.asset(
          image,
          alignment: Alignment.centerLeft,
          repeat: ImageRepeat.repeatX,
        ),
      );
    }

    Widget _buildPerson() {
      return Positioned(
        left: 56,
        top: 0,
        bottom: 0,
        child: Image.asset(
          "assets/images/person_${spaceOn && !pause ? "down" : "up"}.png",
          fit: BoxFit.fitHeight,
          alignment: Alignment.centerLeft,
        ),
      );
    }

    Widget _buildCalendar() {
      return Positioned(
        right: 56,
        top: 56,
        height: 128,
        width: 128,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: kElevationToShadow[4],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Container(
                  height: 32,
                  width: double.infinity,
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat("MMM, yyyy", 'pt').format(currentDate).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 96,
                  width: double.infinity,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Text(
                    currentDate.day.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildPause() {
      return Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black.withOpacity(0.75),
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(height: 156),
            Text(
              result != null
                  ? result!
                      ? "VOCÊ GANHOU!"
                      : "VOCÊ SOBREVIVEU ${currentDate.difference(initialDate).inDays} DIAS!\n${points.toStringAsFixed(2)} PONTOS"
                  : start
                      ? "APERTE ESPAÇO\nPARA COMEÇAR"
                      : "PAUSADO",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 96,
              ),
            ),
            const SizedBox(height: 156),
            if (result == null) const Text(
              "Para desviar dos sentimentos ruins, segure a tecla barra de espaço",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: focus,
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyUpEvent && spaceOn) {
            setState(() {
              spaceOn = false;
              if (pause && result != null) {
                reset();
              }
              pause = false;
              onStart();
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.space) && event is RawKeyDownEvent) {
            setState(() => spaceOn = true);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(pause ? Icons.play_circle : Icons.pause_circle),
                    onPressed: togglePause,
                    iconSize: 48,
                    color: Colors.white,
                  ),
                  const Text(
                    "Era pra ser 15 dias, mas...",
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 64),
                ],
              ),
            ),
            const Spacer(),
            AspectRatio(
              aspectRatio: 8 / 3,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final prop = constraints.constrainHeight() / 1080;
                  final playerBox = Rectangle(56 + 53 * prop, 557 * prop, 117 * prop, 123 * prop);
                  final gameBox =
                      Rectangle(0, 0, constraints.constrainWidth(), constraints.constrainHeight());

                  Widget _buildProjectile(Projectile proj) {
                    final projBox = Rectangle(
                      constraints.constrainWidth() - proj.offset * 1.5 - 400 * prop,
                      proj.top(prop),
                      400 * prop,
                      400 * prop,
                    );

                    if (playerBox.intersects(projBox) && !spaceOn) {
                      WidgetsBinding.instance!.addPostFrameCallback((_) => endGame());
                    } else if (!gameBox.intersects(projBox)) {
                      WidgetsBinding.instance!.addPostFrameCallback((_) => getNewProjectile());
                    }

                    return AnimatedPositioned(
                      top: proj.top(prop),
                      height: 400 * prop,
                      width: 400 * prop,
                      right: proj.offset * 1.5,
                      duration: const Duration(milliseconds: 33),
                      child: Image.asset(
                        proj.image,
                        height: 400 * prop,
                        width: 400 * prop,
                        fit: BoxFit.contain,
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      _buildImage('assets/images/layers/l0.png', 1),
                      _buildImage('assets/images/layers/l1.png', 1.1),
                      _buildImage('assets/images/layers/l2.png', 1.2),
                      _buildImage('assets/images/layers/l3.png', 1.3),
                      _buildPerson(),
                      for (var proj in projectiles) _buildProjectile(proj),
                      _buildCalendar(),
                      if (pause) _buildPause(),
                    ],
                  );
                },
              ),
            ),
            const Spacer(),
            Text(
              "Pontuação: ${points.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

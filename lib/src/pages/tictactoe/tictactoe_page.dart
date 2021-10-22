// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({Key? key}) : super(key: key);

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  List<List<Field>> game = [
    [Field.open, Field.open, Field.open],
    [Field.open, Field.open, Field.open],
    [Field.open, Field.open, Field.open],
  ];

  List<List<double>> angles = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
  ];

  final player1 = Player.x();
  final player2 = Player.o();

  var turn = 0;

  Player get currentPlayer => [player1, player2][turn];
  Result? result;
  String? resultImage;

  bool showTrophy = false;

  final rand = Random();

  void play(int i, int j) {
    if (result == null) {
      setState(() {
        game[i][j] = currentPlayer.field;
        angles[i][j] = rand.nextDouble() * 30 * (rand.nextBool() ? 1 : -1) * pi / 180;
      });
      completeTurn();
    }
  }

  void completeTurn() {
    if (evaluateGame()) {
      // Game Over
      Future.delayed(const Duration(seconds: 1)).then((_) {
        if ([Result.o, Result.x].contains(result)) {
          setState(() {
            showTrophy = true;
          });
        }
      });
      setState(() {});
    } else {
      // Next Turn
      setState(() {
        if (turn == 0) {
          turn = 1;
        } else {
          turn = 0;
        }
      });
    }
  }

  Result? resultFromField(Field f) {
    if (f == Field.x) {
      return Result.x;
    } else if (f == Field.o) {
      return Result.o;
    } else {
      return null;
    }
  }

  Player? playerFromField(Field f) {
    if (f == Field.x) {
      return player1;
    } else if (f == Field.o) {
      return player2;
    } else {
      return null;
    }
  }

  Player? winner() {
    if (result == Result.o) {
      return player2;
    } else if (result == Result.x) {
      return player1;
    } else {
      return null;
    }
  }

  bool allEqual(List<Field> fields, [Field? field]) {
    return fields.isNotEmpty &&
        fields[0] != Field.open &&
        fields.every((f) => f == (field ?? fields[0]));
  }

  bool allOpenOrEqualTo(List<Field> fields, Field field) {
    return fields.isNotEmpty && fields.every((f) => [Field.open, field].contains(f));
  }

  bool evaluateGame() {
    for (var i = 0; i < game.length; i++) {
      if (allEqual(game[i])) {
        result = resultFromField(game[i][0]);
        resultImage = "assets/images/tictactoe/i$i.png";
        return true;
      }
      final col = game.map((arr) => arr[i]).toList();
      if (allEqual(col)) {
        result = resultFromField(col[0]);
        resultImage = "assets/images/tictactoe/j$i.png";
        return true;
      }
    }
    final diag1 = [game[0][0], game[1][1], game[2][2]];
    final diag2 = [game[2][0], game[1][1], game[0][2]];
    if (allEqual(diag1)) {
      result = resultFromField(diag1[0]);
      resultImage = "assets/images/tictactoe/d1.png";
      return true;
    }
    if (allEqual(diag2)) {
      result = resultFromField(diag2[0]);
      resultImage = "assets/images/tictactoe/d2.png";
      return true;
    }
    if (game.every((lines) => lines.every((field) => field != Field.open))) {
      result = Result.tie;
      return true;
    }
    return false;
  }

  void reset() {
    setState(() {
      game = [
        [Field.open, Field.open, Field.open],
        [Field.open, Field.open, Field.open],
        [Field.open, Field.open, Field.open],
      ];
      result = null;
      resultImage = null;
      turn = 0;
      showTrophy = false;
    });
  }

  bool isEmpty() {
    return game.every((lines) => lines.every((field) => field == Field.open));
  }

  Future<void> computeBestMove() async {
    await Future.delayed(const Duration(milliseconds: 1));
    final moves = getMoves(copy(game), currentPlayer.field);
    final move = minimax(moves, currentPlayer.field);
    play(move.i, move.j);
  }

  List<MoveModel> getMoves(List<List<Field>> table, Field current) {
    final result = <MoveModel>[];
    for (var i = 0; i <= 2; i++) {
      for (var j = 0; j <= 2; j++) {
        if (table[i][j] == Field.open) {
          final move = MoveModel(i, j, current);
          final newTable = copy(table);
          newTable[i][j] = current;
          move.value = evaluateTable(newTable, current);
          if (move.value.abs() != 9) move.moves = getMoves(newTable, nextPlayer(current));
          result.add(move);
        }
      }
    }
    return result;
  }

  int evaluateTable(List<List<Field>> table, Field current) {
    final x = evaluateTableFor(table, Field.x);
    final o = evaluateTableFor(table, Field.o);

    if (x == 9) return (current == Field.x ? 1 : -1) * 9;
    if (o == 9) return (current == Field.o ? 1 : -1) * 9;

    if (current == Field.x) return x - o;
    return o - x;
  }

  int evaluateTableFor(List<List<Field>> table, Field field) {
    var result = 0;
    for (var i = 0; i <= 2; i++) {
      if (allEqual(table[i], field)) return 9;
      if (allOpenOrEqualTo(table[i], field)) result += 1;

      final col = table.map((arr) => arr[i]).toList();
      if (allEqual(col, field)) return 9;
      if (allOpenOrEqualTo(col, field)) result += 1;
    }
    final diag1 = [table[0][0], table[1][1], table[2][2]];
    if (allOpenOrEqualTo(diag1, field)) result += 1;
    if (allEqual(diag1, field)) return 9;

    final diag2 = [table[2][0], table[1][1], table[0][2]];
    if (allOpenOrEqualTo(diag2, field)) result += 1;
    if (allEqual(diag2, field)) return 9;

    return result;
  }

  MoveModel minimax(List<MoveModel> moves, Field turn) {
    // print(moves);
    moves.sort((a, b) {
      double aValue = a.getMinimaxValue(turn) + a.random;
      double bValue = b.getMinimaxValue(turn) + b.random;
      return bValue.compareTo(aValue);
    });
    return moves[0];
  }

  List<List<Field>> copy(List<List<Field>> table) {
    final result = <List<Field>>[];
    for (var l in table) {
      result.add([...l]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (currentPlayer.isComputer) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        computeBestMove();
      });
    }
    Widget _buildCell(int i, int j) {
      const side = BorderSide(color: Colors.white, width: 4);
      const none = BorderSide.none;
      final field = game[i][j];
      final cellPlayer = playerFromField(field);
      return GestureDetector(
        onTap: () {
          if (field == Field.open && !currentPlayer.isComputer) play(i, j);
        },
        child: Container(
          height: 160,
          width: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              top: i == 0 ? none : side,
              bottom: i == 2 ? none : side,
              left: j == 0 ? none : side,
              right: j == 2 ? none : side,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: field == Field.open
              ? null
              : Transform.rotate(angle: angles[i][j], child: Image.asset(cellPlayer!.image)),
        ),
      );
    }

    Widget _buildRows(int i) =>
        Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (j) => _buildCell(i, j)));

    Widget _buildResultImage() {
      return AnimatedCrossFade(
        firstChild: Image.asset(resultImage!, fit: BoxFit.cover, color: Colors.red[900]),
        secondChild: const SizedBox(height: 480, width: 480),
        crossFadeState: result != null && resultImage != null
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 200),
      );
    }

    Widget _buildResultText() {
      return Text(
        result == Result.tie
            ? "Deu velha!\nO jogo empatou!"
            : "Parabéns ${winner()!.fixedName}!\nVocê ganhou!",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 48,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    Widget _buildIcon(Player player) {
      return GestureDetector(
        onTap: () {
          // if (isEmpty()) setState(() => player.isComputer = !player.isComputer);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
              color: const Color(0xFF1A3676),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(player.image),
          ),
        ),
      );
    }

    Widget _buildName(Player player) {
      const b = OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );
      final dec = InputDecoration(
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintText: player.baseName,
        border: b,
        errorBorder: b,
        enabledBorder: b,
        focusedBorder: b,
        disabledBorder: b,
        focusedErrorBorder: b,
      );
      return SizedBox(
        height: 48,
        width: 240,
        child: player.isComputer
            ? TextField(
                key: Key(player.robotName),
                enabled: false,
                textAlign: TextAlign.center,
                decoration: dec.copyWith(hintText: player.robotName),
                style: const TextStyle(color: Colors.white, height: 1),
              )
            : TextField(
                key: Key(player.baseName),
                enabled: isEmpty(),
                textAlign: TextAlign.center,
                onChanged: (v) => player.name = v,
                style: const TextStyle(color: Colors.white, height: 1),
                decoration: dec,
              ),
      );
    }

    Widget _buildTextFields() {
      return SingleChildScrollView(
        primary: false,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: 64,
          width: 768,
          child: Row(
            children: [
              const SizedBox(width: 24),
              _buildIcon(player1),
              const SizedBox(width: 24),
              _buildName(player1),
              const SizedBox(width: 32),
              const Text(
                "vs",
                style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 32),
              _buildName(player2),
              const SizedBox(width: 24),
              _buildIcon(player2),
              const SizedBox(width: 24),
            ],
          ),
        ),
      );
    }

    Widget _buildReset() {
      return ElevatedButton(
        onPressed: reset,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(32)),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        child: const Text(
          "NOVO JOGO",
          style: TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.w700),
        ),
      );
    }

    Widget _buildTrophy() {
      return AnimatedOpacity(
        opacity: showTrophy ? 1 : 0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.all(64),
          child: Image.asset("assets/images/tictactoe/trofeu.png", fit: BoxFit.contain),
        ),
      );
    }

    return Scaffold(
      // backgroundColor: Colors.purple[900],
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A3676),
              Color(0xFF2F014B),
              Color(0xFF1A3676),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 64),
              _buildTextFields(),
              const SizedBox(height: 128),
              SizedBox(
                height: 480,
                width: 480,
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, _buildRows),
                    ),
                    if (resultImage != null) _buildResultImage(),
                    if (showTrophy) _buildTrophy(),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              if (result != null) _buildResultText(),
              const SizedBox(height: 48),
              _buildReset(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class Player {
  String baseName;
  String robotName;
  String name = '';
  Field field;
  bool isComputer = false;

  Player.x()
      : field = Field.x,
        baseName = "Karla",
        robotName = "Robô Karla",
        name = "Karla";
  Player.o()
      : field = Field.o,
        baseName = "José",
        robotName = "Robô José",
        name = "José";

  int wins = 0;

  String get image => isComputer ? field.robotImage : field.image;

  String get fixedName => isComputer
      ? robotName
      : name.isEmpty
          ? baseName
          : name;
}

enum Field { open, x, o }
enum Result { tie, x, o }

extension on Field {
  String get name {
    switch (this) {
      case Field.o:
        return "O";
      case Field.x:
        return "X";
      default:
        return " ";
    }
  }

  String get image {
    switch (this) {
      case Field.o:
        return "assets/images/tictactoe/O.png";
      case Field.x:
        return "assets/images/tictactoe/X.png";
      default:
        return "";
    }
  }

  String get robotImage {
    switch (this) {
      case Field.o:
        return "assets/images/tictactoe/rO.png";
      case Field.x:
        return "assets/images/tictactoe/rX.png";
      default:
        return "";
    }
  }
}

class MoveModel {
  int i, j;
  int value = 0;

  Field turn;

  double random = Random().nextDouble() / 2;

  List<MoveModel> moves = [];

  MoveModel(this.i, this.j, this.turn);

  int? _minimaxValue;

  int getMinimaxValue(Field current) {
    if (_minimaxValue != null) return _minimaxValue!;
    if (moves.isEmpty) {
      _minimaxValue = value;
      return value;
    }
    final numbers = moves.map((e) => e.getMinimaxValue(current)).toList();
    numbers.sort();
    if (current == turn) {
      _minimaxValue = numbers.first;
      return numbers.first;
    } else {
      _minimaxValue = numbers.last;
      return numbers.last;
    }
  }

  @override
  String toString() {
    String result = "Turno: ${turn.name} -> $i, $j -> ${getMinimaxValue(turn)}";
    // for (var move in moves) {
    //   result += "\n    $move";
    // }
    return result;
  }
}

Field nextPlayer(Field f) => f == Field.x ? Field.o : Field.x;

void printTable(List<List<Field>> table) {
  var i = 1;
  for (var l in table) {
    print(l.map((e) => e.name).toString() + "." * i++);
  }
}

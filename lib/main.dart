import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DerpySnek(),
    );
  }
}

class DerpySnek extends StatefulWidget {
  @override
  _DerpySnekState createState() => _DerpySnekState();
}

class _DerpySnekState extends State<DerpySnek> {
  final fontStyle = TextStyle(color: Colors.white, fontSize: 21);

  //random generator for the food dots
  final randGen = Random();

  //Code handles game # of tiles
  final int tilesRow = 20;
  final int tilesCol = 40;

  //Buffer for spacing of the score and start/end game button
  // at the bottom of the screen
  final int buffer = 5;

  var snek = [
    [0, 1],
    [0, 0]
  ];

  //position in array the snax are
  var snax = [5, 10];
  //starts facing and moving upwards
  var direction = 'up';
  //determines if game is running
  var isPlaying = false;

  void startGame() {
    //duration handles the "tick" speed at which the snek moves.
    //Adjust lower for a faster snek and higher for slower snek
    const duration = Duration(milliseconds: 225);

    //sets snek head position
    snek = [
      [(tilesRow / 2).floor(), (tilesCol / 2).floor()]
    ];
    snek.add([snek.first[0], snek.first[1]-1]); //Body of snek
    summonSnax();
    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      snekMove();
      if (gameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void summonSnax() {
    snax = [
      randGen.nextInt(tilesRow),
      randGen.nextInt(tilesCol)
    ];
  }

  void snekMove() {
    setState(() {
      switch (direction) {
        case 'up':
          snek.insert(0, [snek.first[0], snek.first[1] - 1]);
          break;
        case 'down':
          snek.insert(0, [snek.first[0], snek.first[1] + 1]);
          break;
        case 'left':
          snek.insert(0, [snek.first[0] - 1, snek.first[1]]);
          break;
        case 'right':
          snek.insert(0, [snek.first[0] + 1, snek.first[1]]);
          break;
      }

      if (snek.first[0] != snax[0] || snek.first[1] != snax[1])
        snek.removeLast();
      else {
        summonSnax();
      }
    });
  }

  bool gameOver() {
    if (!isPlaying ||
        snek.first[1] < 0 ||
        snek.first[1] >= tilesCol ||
        snek.first[0] < 0 ||
        snek.first[0] >= tilesRow) {
      return true;
    }

    for (var i = 1; i < snek.length; ++i) {
      if (snek[i][0] == snek.first[0] && snek[i][1] == snek.first[1]) {
        return true;
      }
    }
    return false;
  }

  void endGame() {
    isPlaying = false;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ded Snek :('),
            content: Text(
              'Score: ${snek.length - 2}',
              style: TextStyle(fontSize: 24),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              )
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
            child: AspectRatio(
              aspectRatio: (tilesRow / (tilesCol + buffer)),
              child: GridView.builder(
                //you cant scroll the page
                physics: NeverScrollableScrollPhysics(),
                //making the grid
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: tilesRow,
                ),
                itemCount: tilesCol * tilesRow,
                itemBuilder: (BuildContext context, int index) {
                  var color;
                  //used to generate the aspect ratio for device scaling
                  var x = index % tilesRow;
                  var y = (index / tilesRow).floor();

                  bool isSnek = false;
                  for (var pos in snek) {
                    if (pos[0] == x && pos[1] == y) {
                      isSnek = true;
                      break;
                    }
                  }

                  if (snek.first[0] == x && snek.first[1] == y) {
                    color = Colors.green;
                  } else if (isSnek) {
                    color = Colors.lightGreen;
                  } else if (snax[0] == x && snax[1] == y) {
                    color = Colors.red;
                  } else {
                    color = Colors.grey[800];
                  }

                  return Container(
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.rectangle,
                    ),
                  );
                },
              ),
            ),
          )),
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                      onPressed: () {
                        if (isPlaying) {
                          isPlaying = false;
                        } else {
                          startGame();
                        }
                      },
                      child: Text(
                        isPlaying ? 'Kill Snek?' : 'Play Snek',
                        style: fontStyle,
                      )),
                  Text(
                    'Score: ${snek.length - 2}',
                    style: fontStyle,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}

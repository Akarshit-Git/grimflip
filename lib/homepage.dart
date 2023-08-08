import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:grimflip/barrier.dart';
import 'package:grimflip/ghost.dart';

import 'package:assets_audio_player/assets_audio_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //ghost variables
  static double ghostY = 0;
  double time = 0;
  double height = 0;
  double initialPos = ghostY;
  double ghostHeight = 0.15;
  double ghostWidth = 0.15;

  bool gameHasStarted = false;

  //barrier variables
  static List<double> barrierX = [2, 2 + 1.5, 2 + 3, 2 + 4.5];
  static double barrierWidth = 0.5;
  List<List<double>> barrierHeight = [
    [0.4, 0.6],
    [0.7, 0.5],
    [0.4, 0.7],
    [0.8, 0.2]
  ];

  int currentScore = 0, bestScore = 0;

  bool audioPlaying = true;
  AssetsAudioPlayer audioPlayer =
      AssetsAudioPlayer(); // this will create a instance object of a class

  @override
  void initState() {
    super.initState();
    getBestScore();
    audioPlayer.open(Audio('lib/audio/Streets_DojaCat.mp3'));
  }

  void jump() {
    setState(() {
      time = 0;
      initialPos = ghostY;
    });
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      //equation used: y = -gt^2/2 + vt
      //gravity = -9.8
      height = -4.9 * time * time + 2.8 * time;

      setState(() {
        ghostY = initialPos - height;
      });

      if (gameOver()) {
        timer.cancel();
        if (currentScore > bestScore) {
          updateBestScore();
          getBestScore();
        }
        _showGameOverDialog();
      }

      moveMap();
      updateCurrentScore();

      time += 0.009;
    });
  }

  bool gameOver() {
    //hitting top or bottom
    if (ghostY > 1 || ghostY < -1) {
      return true;
    }

    //hitting barriers
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= ghostWidth &&
          barrierX[i] + barrierWidth >= -ghostWidth &&
          (ghostY <= -1 + barrierHeight[i][0] ||
              ghostY + ghostHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }

    return false;
  }

  void moveMap() {
    for (int i = 0; i < barrierX.length; i++) {
      setState(() {
        barrierX[i] -= 0.005;
      });

      // if (barrierX[i] < -1.5) {
      //   barrierX[i] += 3;
      // }
      if (barrierX[i] < -4.5) {
        barrierX[i] += 6;
      }
    }
  }

  void updateCurrentScore() {
    if (barrierX[0].toString().startsWith('-0.499') ||
        barrierX[1].toString().startsWith('-0.499') ||
        barrierX[2].toString().startsWith('-0.499') ||
        barrierX[3].toString().startsWith('-0.499')) {
      setState(() {
        currentScore += 1;
      });
    }
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      ghostY = 0;
      gameHasStarted = false;
      time = 0;
      initialPos = ghostY;
      barrierX = [2, 2 + 1.5, 2 + 3, 2 + 4.5];
      currentScore = 0;
    });
  }

  void _showGameOverDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey,
            title: const Center(
              child: Text('G A M E   O V E R',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.leaderboard,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: resetGame,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 5,
                                    spreadRadius: 0.5),
                                BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-2.0, -2.0),
                                    blurRadius: 5,
                                    spreadRadius: 0.5)
                              ]),
                          child: const Text(
                            'PLAY AGAIN',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black,
                      child: IconButton(
                          onPressed: () {
                            audioPlaying
                                ? audioPlayer.pause()
                                : audioPlayer.play();

                            setState(() {
                              audioPlaying = !audioPlaying;
                            });
                          },
                          icon: Icon(
                              audioPlaying
                                  ? Icons.volume_mute
                                  : Icons.volume_up,
                              size: 20,
                              color: Colors.white)),
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: AssetImage('lib/images/BG1.jpg'))),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        alignment: Alignment(0, ghostY),
                        duration: const Duration(milliseconds: 0),
                        //color: Colors.black,
                        child: MyGhost(
                          ghostY: ghostY,
                          ghostHeight: ghostHeight,
                          ghostWidth: ghostWidth,
                        ),
                      ),
                      Container(
                        alignment: const Alignment(0, -0.25),
                        child: gameHasStarted
                            ? const Text("")
                            : const Text("T A P   T O   P L A Y",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                      ),
                      MyBarrier(
                          barrierHeight: barrierHeight[0][0],
                          barrierWidth: barrierWidth,
                          isThisBottomBarrier: false,
                          barrierX: barrierX[0]),
                      MyBarrier(
                          barrierHeight: barrierHeight[0][1],
                          barrierWidth: barrierWidth,
                          isThisBottomBarrier: true,
                          barrierX: barrierX[0]),
                      MyBarrier(
                          barrierHeight: barrierHeight[1][0],
                          barrierWidth: barrierWidth,
                          isThisBottomBarrier: false,
                          barrierX: barrierX[1]),
                      MyBarrier(
                          barrierHeight: barrierHeight[1][1],
                          barrierWidth: barrierWidth,
                          isThisBottomBarrier: true,
                          barrierX: barrierX[1]),
                      MyBarrier(
                          barrierHeight: barrierHeight[2][0],
                          barrierWidth: barrierWidth,
                          isThisBottomBarrier: false,
                          barrierX: barrierX[2]),
                      MyBarrier(
                          barrierHeight: barrierHeight[2][1],
                          barrierWidth: barrierWidth,
                          isThisBottomBarrier: true,
                          barrierX: barrierX[2]),
                      MyBarrier(
                          barrierHeight: barrierHeight[3][0],
                          barrierWidth: barrierWidth,
                          isThisBottomBarrier: false,
                          barrierX: barrierX[3]),
                      MyBarrier(
                          barrierHeight: barrierHeight[3][1],
                          barrierWidth: barrierWidth,
                          isThisBottomBarrier: true,
                          barrierX: barrierX[3]),
                    ],
                  ),
                )),
            Container(
              height: 15,
              color: Colors.redAccent,
            ),
            Expanded(
                child: Container(
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Expanded(
                  //   flex: 2,
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: const [
                  //       CircleAvatar(
                  //         radius: 18,
                  //         backgroundColor: Colors.black,
                  //         child: Icon(
                  //           Icons.leaderboard,
                  //           size: 20,
                  //           color: Colors.redAccent,
                  //         ),
                  //       ),
                  //       SizedBox(height: 15),
                  //       CircleAvatar(
                  //         radius: 18,
                  //         backgroundColor: Colors.black,
                  //         child: Icon(
                  //           Icons.speaker,
                  //           size: 20,
                  //           color: Colors.redAccent,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$currentScore',
                          style: const TextStyle(
                            fontSize: 45,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Best',
                          style: TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$bestScore',
                          style: const TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  getBestScore() async {
    final response = await http
        .get(Uri.parse('http://192.168.0.127:3000/scores')); //System IP Address
    var jsonResponse = convert.jsonDecode(response.body);

    setState(() {
      bestScore = jsonResponse[0]['Best'];
    });
  }

  updateBestScore() {
    return http.post(
      Uri.parse('http://192.168.0.127:3000/updateScores'), //System IP Address
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'Best': currentScore, 'Player_ID': 1}),
    );
  }
}

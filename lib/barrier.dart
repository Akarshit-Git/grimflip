import 'package:flutter/material.dart';

class MyBarrier extends StatelessWidget {
  final double barrierHeight;
  final double barrierWidth;
  final double barrierX;
  final bool isThisBottomBarrier;

  const MyBarrier(
      {required this.barrierHeight,
      required this.barrierWidth,
      required this.isThisBottomBarrier,
      required this.barrierX,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment((2 * barrierX + barrierWidth) / (2 - barrierWidth),
          isThisBottomBarrier ? 1.0 : -1.0),
      child: Container(
        width: MediaQuery.of(context).size.width * barrierWidth / 2,
        height: MediaQuery.of(context).size.height * 3 / 4 * barrierHeight / 2,
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 5,
              color: Colors.white,
            )),
        child: Image.asset(
          'lib/images/stone_pattern2.jpg',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

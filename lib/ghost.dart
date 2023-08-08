import 'package:flutter/material.dart';

class MyGhost extends StatelessWidget {
  final double ghostY;
  final double ghostWidth;
  final double ghostHeight;

  const MyGhost(
      {required this.ghostY,
      required this.ghostWidth,
      required this.ghostHeight,
      Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(0, (2 * ghostY + ghostHeight) / (2 - ghostHeight)),
        child: Image.asset(
          'lib/images/Ghost.png',
          width: MediaQuery.of(context).size.height * ghostWidth / 2,
          height: MediaQuery.of(context).size.height * 3 / 4 * ghostHeight / 2,
          fit: BoxFit.fill,
        ));
  }
}

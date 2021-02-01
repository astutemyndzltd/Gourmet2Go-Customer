import '../../src/repository/user_repository.dart';
import 'package:flutter/material.dart';

class UserAvatarWidget extends StatelessWidget {

  final double dimension;
  final double textFontSize;
  final VoidCallback onTap;
  final String text;

  final List<Color> colors = [
    Colors.teal, //a
    Colors.pink, //b
    Colors.deepPurple, //c
    Colors.green, //d
    Colors.blueAccent, //e
    Colors.deepOrange, //f
    Colors.indigo, //g
    Colors.blue, //h
    Colors.red, //i
    Colors.blueGrey, //j
    Colors.lightBlue, //k
    Colors.brown, //l
    Colors.indigoAccent, //m
    Colors.purple, //n
    Colors.lightGreen, //o
    Colors.teal, //p
    Colors.pink, //q
    Colors.deepPurple, //r
    Colors.green, //s
    Colors.blueAccent, //t
    Colors.deepOrange, //u
    Colors.indigo, //v
    Colors.blue, //w
    Colors.red, //x
    Colors.blueGrey, //y
    Colors.cyan, //z
  ];

  UserAvatarWidget({this.dimension, this.textFontSize, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: this.dimension,
      height: this.dimension,
      child: InkWell(
        borderRadius: BorderRadius.circular(300),
        onTap: () => this.onTap?.call(),
        child: Container(
          decoration: BoxDecoration(
            color: colors[text.toUpperCase().codeUnitAt(0) - 65],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              text.substring(0, 1).toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: this.textFontSize),
            ),
          ),
        ),
      ),
    );
  }
}

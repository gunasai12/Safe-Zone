import 'package:flutter/material.dart';

const gradientBackground = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.02, 0.21, 0.21, 0.22, 0.40, 0.40, 0.60, 0.60, 0.75, 0.76, 0.77, 0.89, 0.97, 0.99, 1.0, 1.0, 0.98],
    colors: [
      Color.fromRGBO(216, 216, 224, 1),
      Color.fromRGBO(243, 248, 247, 1),
      Color.fromRGBO(248, 248, 248, 1),
      Color.fromRGBO(255, 255, 255, 1),
      Color.fromRGBO(248, 248, 248, 1),
      Color.fromRGBO(248, 248, 248, 1),
      Color.fromRGBO(255, 255, 255, 1),
      Color.fromRGBO(241, 249, 249, 1),
      Color.fromRGBO(251, 255, 254, 1),
      Color.fromRGBO(248, 248, 248, 1),
      Color.fromRGBO(255, 255, 255, 1),
      Color.fromRGBO(253, 255, 255, 1),
      Color.fromRGBO(248, 244, 242, 1),
      Color.fromRGBO(245, 255, 253, 1),
      Color.fromRGBO(251, 252, 252, 1),
      Color.fromRGBO(230, 230, 229, 1),
      Color.fromRGBO(250, 251, 251, 1),
      Color.fromRGBO(248, 231, 231, 1),
    ],
  ),
);

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradientBackground,
      child: child,
    );
  }
}

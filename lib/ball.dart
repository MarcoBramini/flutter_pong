import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pong/pong.dart';

class Ball {
  Offset _offset;

  // Ball speed px/s
  double ballSpeedX = 30.0;
  double ballSpeedY = 30.0;

  Ball() {
    _offset = Offset(0.0, 0.0);
  }

  Offset get offset => _offset;

  setBallPosition(double dx, double dy) => _offset = Offset(dx, dy);

  render(Canvas canvas) {
    canvas.drawCircle(Offset(_offset.dx, _offset.dy), ballRadius,
        Paint()..color = Colors.lightGreenAccent);
  }
}

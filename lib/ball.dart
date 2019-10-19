import 'package:flutter/material.dart';
import 'package:flutter_pong/pong.dart';

class Velocity {
  double vx;
  double vy;

  Velocity(this.vx, this.vy);
}

class Ball {
  Offset _offset;
  Velocity _velocity;

  Ball(double dx, double dy, double vx, double vy) {
    _offset = Offset(dx, dy);
    _velocity = Velocity(vx, vy);
  }

  Offset get offset => _offset;

  Velocity get velocity => _velocity;

  setBallPosition(double dx, double dy) => _offset = Offset(dx, dy);

  render(Canvas canvas) {
    canvas.drawCircle(Offset(_offset.dx, _offset.dy), ballRadius,
        Paint()..color = Colors.lightGreenAccent);
  }
}

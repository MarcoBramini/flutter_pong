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

  bool isWithinXWalls(double width) =>
      _offset.dx - ballRadius > 0 && _offset.dx + ballRadius < width;

  bool isWithinTopWall() => _offset.dy - ballRadius > 0;

  bool isWithinBottomWall(double height) => _offset.dy + ballRadius < height;

  bool didHitAnotherObject(
      double objXOffset, double objYOffset, double objHeight, double objWidth) {
    bool res = false;
    calculateSamplePoints().forEach((Offset p) {
      if (isPointWithinRect(
          p.dx, p.dy, objXOffset, objYOffset, objHeight, objWidth)) {
        res = true;
      }
    });
    return res;
  }

  List<Offset> calculateSamplePoints() {
    List<Offset> samplePoints = new List<Offset>();
    for (double i = 0; i < 2 * pi; i += pi / 4) {
      Offset p = Offset(_offset.dx + (ballRadius * sin(i)),
          _offset.dy + (ballRadius * cos(i)));
      samplePoints.add(p);
    }
    return samplePoints;
  }

  bool isPointWithinRect(double pointX, double pointY, double objXOffset,
      double objYOffset, double objHeight, double objWidth) {
    return pointY >= objYOffset &&
        pointY <= objYOffset + objHeight &&
        pointX >= objXOffset &&
        pointX <= objXOffset + objWidth;
  }
}

import 'package:flutter/material.dart';

class Court {
  double height;
  double width;

  Court(this.height, this.width);

  double getCenteredObjectXOffset([double objWidth = 0]) =>
      (width - objWidth) / 2;

  double getCenteredObjectYOffset([double objHeight = 0]) =>
      (height - objHeight) / 2;

  double getYOffsetFromBottomWithAddedDistance(
          double objHeight, double distanceFromBottom) =>
      height - objHeight - distanceFromBottom;

  render(Canvas canvas) {
    canvas.drawLine(Offset(0, height / 2), Offset(width, height / 2),
        Paint()..color = Colors.lightGreenAccent);
  }
}

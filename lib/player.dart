import 'package:flutter/material.dart';
import 'package:flutter_pong/pong.dart';

class Player {
  Offset _offset;
  double _lastXOffset;

  Player() {
    _offset = Offset(0.0, 0.0);
  }

  Offset get offset => _offset;

  double get lastXOffset => _lastXOffset;

  setPlayerCursorOffset(double dx, [double dy]) {
    if (dy == null) {
      dy = _offset.dy;
    }
    _offset = Offset(dx, dy);
  }

  setPlayerCursorLastXOffset(double dx) => _lastXOffset = dx;

  render(Canvas canvas) {
    canvas.drawRect(
        Rect.fromLTWH(_offset.dx, _offset.dy, cursorWidth, cursorHeight),
        Paint()..color = Colors.indigo);
  }
}

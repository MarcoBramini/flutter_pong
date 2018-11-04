import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_pong/ball.dart';
import 'package:flutter_pong/court.dart';
import 'package:flutter_pong/player.dart';

// Configs
const double cursorHeight = 5.0;
const double cursorDistanceFromYWalls = 50.0;
const double cursorWidth = 100.0;
const double ballRadius = 5;

class Pong extends RenderBox {
  double ballDiameter = ballRadius * 2;

  Court _court;

  Ball _ball;

  Player _player1;
  double player1LastXOffset;

  Player _player2;
  double player2LastXOffset;

  Pong();

  void setup() {
    _court = Court(constraints.maxHeight, constraints.maxWidth);
    print(_court.getCenteredObjectYOffset().toString() +
        " " +
        _court.height.toString());

    _ball = Ball()
      ..setBallPosition(
          _court.getCenteredObjectXOffset(), _court.getCenteredObjectYOffset());

    _player1 = Player()
      ..setPlayerCursorOffset(_court.getCenteredObjectXOffset(cursorWidth),
          cursorDistanceFromYWalls);

    _player2 = Player()
      ..setPlayerCursorOffset(
          _court.getCenteredObjectXOffset(cursorWidth),
          _court.getYOffsetFromBottomWithAddedDistance(
              cursorHeight, cursorDistanceFromYWalls));

    GestureBinding.instance.pointerRouter.addGlobalRoute((PointerEvent e) {
      if (e is PointerDownEvent) {
        if (e.position.dy < _court.height / 2) {
          _player1.setPlayerCursorLastXOffset(e.position.dx);
        } else {
          _player2.setPlayerCursorLastXOffset(e.position.dx);
        }
      }
      if (e is PointerMoveEvent) {
        if (e.position.dy < _court.height / 2) {
          _player1.setPlayerCursorOffset(
              _player1.offset.dx + e.position.dx - _player1.lastXOffset);
          _player1.setPlayerCursorLastXOffset(e.position.dx);
        } else {
          _player2.setPlayerCursorOffset(
              _player2.offset.dx + e.position.dx - _player2.lastXOffset);
          _player2.setPlayerCursorLastXOffset(e.position.dx);
        }
      }
    });

    startGameLoop();
  }

  @override
  bool get sizedByParent {
    setup();
    return true;
  }

  double speedIncrement = 1.000075;

  int scorePlayer1 = 0;
  int scorePlayer2 = 0;

  void startGameLoop() {
    new Timer.periodic(Duration(milliseconds: 20), (_) {
      run();
      markNeedsPaint();
    });
  }

  void render(Canvas canvas) {
    canvas.drawColor(Colors.black, BlendMode.screen);
    ui.Paragraph p1 = (ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 23.0))
          ..addText(scorePlayer1.toString())
          ..pushStyle(ui.TextStyle(color: Colors.indigo)))
        .build()
          ..layout(ui.ParagraphConstraints(width: 100.0));
    canvas.drawParagraph(p1, Offset(0, (_court.height / 2) - 25.0));

    ui.Paragraph p2 = (ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 23.0))
          ..addText(scorePlayer2.toString())
          ..pushStyle(ui.TextStyle(color: Colors.red)))
        .build()
          ..layout(ui.ParagraphConstraints(width: 100.0));
    canvas.drawParagraph(p2, Offset(0, _court.height / 2));

    _court.render(canvas);
    _ball.render(canvas);
    _player1.render(canvas);
    _player2.render(canvas);
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    render(paintContext.canvas);
  }

  void run() {
    if (!_ball.isWithinXWalls(_court.width)) {
      _ball.ballSpeedX = -_ball.ballSpeedX;
    }

    if (_court.isPointWithinTopHalf(_ball.offset.dy)) {
      if (!_ball.isWithinTopWall()) {
        scorePlayer2++;
        _ball.ballSpeedX = -30.0;
        _ball.ballSpeedY = -30.0;
        _ball
          ..setBallPosition(_court.getCenteredObjectXOffset(ballDiameter),
              _court.getCenteredObjectYOffset(ballDiameter));
      }

      if (_ball.didHitAnotherObject(
          _player1.offset.dx, _player1.offset.dy, cursorHeight, cursorWidth)) {
        _ball.ballSpeedY = -_ball.ballSpeedY;
        if (_ball.offset.dx < _player1.offset.dx + 5.0 &&
                _ball.ballSpeedX > 0 ||
            _ball.offset.dx > _player1.offset.dx + cursorWidth - 5.0 &&
                _ball.ballSpeedX < 0) {
          _ball.ballSpeedX = -_ball.ballSpeedX;
        }
      }
    } else {
      if (!_ball.isWithinBottomWall(_court.height)) {
        scorePlayer1++;
        _ball.ballSpeedX = 30.0;
        _ball.ballSpeedY = 30.0;
        _ball
          ..setBallPosition(_court.getCenteredObjectXOffset(ballDiameter),
              _court.getCenteredObjectYOffset(ballDiameter));
      }

      if (_ball.didHitAnotherObject(
          _player2.offset.dx, _player2.offset.dy, cursorHeight, cursorWidth)) {
        _ball.ballSpeedY = -_ball.ballSpeedY;
        if (_ball.offset.dx < _player2.offset.dx + 5.0 &&
                _ball.ballSpeedX > 0 ||
            _ball.offset.dx > _player2.offset.dx + cursorWidth - 5.0 &&
                _ball.ballSpeedX < 0) {
          _ball.ballSpeedX = -_ball.ballSpeedX;
        }
      }
    }

    _ball.setBallPosition(_ball.offset.dx + _ball.ballSpeedX * 0.02,
        _ball.offset.dy + _ball.ballSpeedY * 0.02);
    _ball.ballSpeedX *= speedIncrement;
    _ball.ballSpeedY *= speedIncrement;
  }
}

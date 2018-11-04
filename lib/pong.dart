import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_pong/ball.dart';
import 'package:flutter_pong/court.dart';
import 'package:flutter_pong/geometry_mixin.dart';
import 'package:flutter_pong/player.dart';

// Configs
const double cursorHeight = 10.0;
const double cursorDistanceFromYWalls = 100.0;
const double cursorWidth = 100.0;
const double ballRadius = 5;

void main() => runApp(PongWidget());

class PongWidget extends SingleChildRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return Pong();
  }
}

class Pong extends RenderBox with GeometryMixin {
  double ballDiameter = ballRadius * 2;

  Court _court;
  Ball _ball;
  Player _player1;
  Player _player2;

  Pong();

  void setup() {
    _court = Court(constraints.maxHeight, constraints.maxWidth);

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
    // Check if ball is within court width
    if (!isCircleWithinVerticalRange(
        _ball.offset.dx, ballRadius, 0, _court.width)) {
      _ball.ballSpeedX = -_ball.ballSpeedX;
    }

    // Only the court half which contains the ball is considerated for collision
    // detection to improve performances
    if (!isPointAboveHorizontalLine(_ball.offset.dy, _court.height / 2)) {
      if (isCircleBelowHorizontalLine(_ball.offset.dy, ballRadius, 0)) {
        scorePlayer2++;
        _ball.ballSpeedX = -30.0;
        _ball.ballSpeedY = -30.0;
        _ball
          ..setBallPosition(_court.getCenteredObjectXOffset(ballDiameter),
              _court.getCenteredObjectYOffset(ballDiameter));
      }

      RectCollisionArea rectCollisionArea = detectCircleRectCollision(
          _ball.offset, ballRadius, _player1.offset, cursorHeight, cursorWidth);

      if (rectCollisionArea != null) {
        doPlayer1CollisionCalculations(rectCollisionArea);
      }
    } else {
      if (isCircleAboveHorizontalLine(
          _ball.offset.dy, ballRadius, _court.height)) {
        scorePlayer1++;
        _ball.ballSpeedX = 30.0;
        _ball.ballSpeedY = 30.0;
        _ball
          ..setBallPosition(_court.getCenteredObjectXOffset(ballDiameter),
              _court.getCenteredObjectYOffset(ballDiameter));
      }

      RectCollisionArea rectCollisionArea = detectCircleRectCollision(
          _ball.offset, ballRadius, _player2.offset, cursorHeight, cursorWidth);

      if (rectCollisionArea != null) {
        doPlayer2CollisionCalculations(rectCollisionArea);
      }
    }

    _ball.setBallPosition(_ball.offset.dx + _ball.ballSpeedX * 0.02,
        _ball.offset.dy + _ball.ballSpeedY * 0.02);
    _ball.ballSpeedX *= speedIncrement;
    _ball.ballSpeedY *= speedIncrement;
  }

  doPlayer1CollisionCalculations(RectCollisionArea rectCollisionArea) {
    if (rectCollisionArea == RectCollisionArea.bottom) {
      _ball.ballSpeedY = -_ball.ballSpeedY;
    }

    if (rectCollisionArea == RectCollisionArea.bottomLeft &&
            _ball.ballSpeedX > 0 ||
        rectCollisionArea == RectCollisionArea.bottomRight &&
            _ball.ballSpeedX < 0) {
      _ball.ballSpeedY = -_ball.ballSpeedY;
      _ball.ballSpeedX = -_ball.ballSpeedX;
    }

    if (rectCollisionArea == RectCollisionArea.bottomLeft &&
            _ball.ballSpeedX < 0 ||
        rectCollisionArea == RectCollisionArea.bottomRight &&
            _ball.ballSpeedX > 0) {
      _ball.ballSpeedY = -_ball.ballSpeedY;
    }

    if (rectCollisionArea == RectCollisionArea.left ||
        rectCollisionArea == RectCollisionArea.right) {
      _ball.ballSpeedX = -_ball.ballSpeedX;
    }
  }

  doPlayer2CollisionCalculations(RectCollisionArea rectCollisionArea) {
    if (rectCollisionArea == RectCollisionArea.top) {
      _ball.ballSpeedY = -_ball.ballSpeedY;
    }

    if (rectCollisionArea == RectCollisionArea.topLeft &&
            _ball.ballSpeedX > 0 ||
        rectCollisionArea == RectCollisionArea.topRight &&
            _ball.ballSpeedX < 0) {
      _ball.ballSpeedY = -_ball.ballSpeedY;
      _ball.ballSpeedX = -_ball.ballSpeedX;
    }

    if (rectCollisionArea == RectCollisionArea.bottomLeft &&
            _ball.ballSpeedX < 0 ||
        rectCollisionArea == RectCollisionArea.bottomRight &&
            _ball.ballSpeedX > 0) {
      _ball.ballSpeedY = -_ball.ballSpeedY;
    }

    if (rectCollisionArea == RectCollisionArea.left ||
        rectCollisionArea == RectCollisionArea.right) {
      _ball.ballSpeedX = -_ball.ballSpeedX;
    }
  }
}

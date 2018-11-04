import 'package:flutter/material.dart';
import 'package:flutter_pong/pong.dart';

void main() => runApp(PongWidget());

class PongWidget extends SingleChildRenderObjectWidget {

  @override
  RenderObject createRenderObject(BuildContext context) {
    return Pong();
  }
}
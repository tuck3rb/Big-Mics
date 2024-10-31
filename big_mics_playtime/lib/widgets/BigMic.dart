// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:big_mics_playtime/objects/game_state.dart';
import 'package:noise_meter/noise_meter.dart';

class BigMic extends StatefulWidget {
  BigMic(
      {Key? key,
      required this.onScoreChanged,
      required this.onGameOver,
      this.rows = 20,
      this.columns = 20,
      this.cellSize = 10.0})
      : super(key: key) {
    assert(10 <= rows);
    assert(10 <= columns);
    assert(5.0 <= cellSize);
  }

  final Function(int) onScoreChanged;
  final VoidCallback onGameOver;
  final int rows;
  final int columns;
  final double cellSize;

  @override
  State<StatefulWidget> createState() => BigMicState(rows, columns, cellSize);

  static BigMicState? of(BuildContext context) {
    return context.findAncestorStateOfType<BigMicState>();
  }
}

class BigMicBoardPainter extends CustomPainter {
  BigMicBoardPainter(this.state, this.cellSize);

  final GameState? state;
  final double cellSize;

  void drawMicrophone(Canvas canvas, double x, double y, Size canvasSize) {
    final double size = cellSize * 2.5; // Increased base size for better detail

    // Metallic silver colors
    final Color baseMetallic = Colors.grey[300]!;
    final Color darkMetallic = Colors.grey[600]!;
    final Color lightMetallic = Colors.grey[100]!;
    final Color meshColor = Colors.grey[800]!;

    // Main body paint with gradient for metallic effect
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightMetallic, baseMetallic, darkMetallic],
        stops: const [0.2, 0.5, 0.8],
      ).createShader(Rect.fromLTWH(x, y - size * 1.5, size, size * 1.5));

    // Mesh background
    final Paint meshBackgroundPaint = Paint()
      ..color = meshColor
      ..style = PaintingStyle.fill;

    // Highlight paint
    final Paint highlightPaint = Paint()
      ..color = lightMetallic
      ..style = PaintingStyle.fill;

    // Draw main body sphere
    Path mainBody = Path();
    RRect bodyShape = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y - size * 1.2, size, size * 1.2),
      Radius.circular(size * 0.5),
    );
    mainBody.addRRect(bodyShape);
    canvas.drawPath(mainBody, bodyPaint);

    // Draw mesh background
    Path meshPath = Path();
    RRect meshShape = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + size * 0.1, y - size * 1.1, size * 0.8, size * 1.0),
      Radius.circular(size * 0.4),
    );
    meshPath.addRRect(meshShape);
    canvas.drawPath(meshPath, meshBackgroundPaint);

    // Draw grille lines
    final Paint grillePaint = Paint()
      ..color = baseMetallic
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.03;

    double grilleStart = y - size * 1.0;
    double grilleEnd = y - size * 0.1;
    double grilleWidth = size * 0.8;
    int numberOfLines = 12;
    double spacing = (grilleEnd - grilleStart) / (numberOfLines - 1);

    for (int i = 0; i < numberOfLines; i++) {
      double yPos = grilleStart + (spacing * i);
      canvas.drawLine(
        Offset(x + size * 0.1, yPos),
        Offset(x + size * 0.9, yPos),
        grillePaint,
      );
    }

    // Draw top cap
    Path topCap = Path();
    topCap.addArc(
      Rect.fromLTWH(x, y - size * 1.3, size, size * 0.2),
      0,
      3.14159 * 2,
    );
    canvas.drawPath(topCap, bodyPaint);

    // Draw bottom mount
    Paint mountPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [baseMetallic, darkMetallic],
      ).createShader(Rect.fromLTWH(x, y, size, size * 0.3));

    Path mount = Path();
    mount.moveTo(x + size * 0.3, y);
    mount.lineTo(x + size * 0.7, y);
    mount.lineTo(x + size * 0.6, y + size * 0.3);
    mount.lineTo(x + size * 0.4, y + size * 0.3);
    mount.close();
    canvas.drawPath(mount, mountPaint);

    // Add highlight reflection
    Path highlight = Path();
    highlight.moveTo(x + size * 0.2, y - size * 0.9);
    highlight.lineTo(x + size * 0.3, y - size * 0.9);
    highlight.lineTo(x + size * 0.25, y - size * 0.3);
    highlight.close();
    canvas.drawPath(highlight, highlightPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw obstacles
    final paintObstacle = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    state?.obstacles.forEach((obstacle) {
      Rect obstacleRect = Rect.fromLTWH(size.width - obstacle.x * cellSize,
          size.height - cellSize * 2, cellSize, cellSize * 2);
      canvas.drawRect(obstacleRect, paintObstacle);
    });

    // Draw microphone sprite
    if (state != null) {
      drawMicrophone(
          canvas,
          10, // x position
          size.height -
              (state!.bigMicY * cellSize), // y position adjusted for jump
          size // canvas size
          );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BigMicState extends State<BigMic> {
  BigMicState(int rows, int columns, this.cellSize) {
    state = GameState(rows, columns);
  }

  double cellSize;
  GameState? state;
  NoiseReading? micValue;
  late NoiseMeter noiseMeter;
  late StreamSubscription<NoiseReading> _streamSubscription;
  Timer? _timer;

  final double gravity = -9.8;
  final double jumpVelocity = 5.0;
  final double groundLevel = 0;
  final double minVol = 60;

  void resetGame() {
    setState(() {
      state = GameState(widget.rows, widget.columns);
      if (_timer == null || !_timer!.isActive) {
        startGameLoop();
      }
    });
  }

  void startGameLoop() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _step();
        widget.onScoreChanged(state?.getScore() ?? -1);
        if (state?.isGameOver ?? false) {
          _timer?.cancel();
          widget.onGameOver();
        }
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initNoiseMeter() async {
    try {
      noiseMeter = NoiseMeter();
      _streamSubscription = noiseMeter.noise.listen(onData);
    } catch (e) {
      print('NoiseMeter could not initialize: $e');
    }
  }

  void onData(NoiseReading? noiseReading) {
    if (noiseReading == null) return;
    setState(() {
      micValue = noiseReading;
      if (micValue!.meanDecibel > minVol && state?.bigMicY == groundLevel) {
        state?.jump(5.0);
      }
    });
  }

  int getCurrentScore() {
    return state!.getScore();
  }

  @override
  void initState() {
    super.initState();
    noiseMeter = NoiseMeter();
    _streamSubscription = noiseMeter.noise.listen(onData);
    startGameLoop();
  }

  void _step() {
    if (state != null) {
      state?.moveObstacles();
      state?.updateJump(gravity, 0.2);
      state?.handleCollision();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BigMicBoardPainter(state, cellSize));
  }
}

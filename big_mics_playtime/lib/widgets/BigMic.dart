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

  @override
  void paint(Canvas canvas, Size size) {
    final paintBox = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final paintObstacle = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    Rect boxRect = Rect.fromLTWH(10,
        size.height - (state?.bigMicY ?? 0) * cellSize, cellSize, 2 * cellSize);
    canvas.drawRect(boxRect, paintBox);

    state?.obstacles.forEach((obstacle) {
      Rect obstacleRect = Rect.fromLTWH(size.width - obstacle.x * cellSize,
          size.height, cellSize, 2 * cellSize);
      canvas.drawRect(obstacleRect, paintObstacle);
    });
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

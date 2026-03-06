import 'dart:async';
import 'package:flutter/material.dart';
import '../data/move_data.dart';

enum GamePhase { idle, input, performance }

class GalaxyGame {
  // ── State ──────────────────────────────────────
  GamePhase phase = GamePhase.idle;
  double inputTimeLeft = 10.0;
  final List<MoveData> danceQueue = [];
  int performIdx = 0;
  int currentFrame = 0;
  int frameReps = 0;
  double frameTimer = 0;
  bool isPausing = false;
  double pauseTimer = 0;
  static const double frameDuration = 0.3; // seconds per frame
  static const double movePauseDuration = 0.5; // gap between moves
  static const int repsPerMove = 1;

  // Callbacks to notify Flutter UI
  VoidCallback? onStateChanged;

  // ── Game loop ───────────────────────────────────
  Timer? _loopTimer;
  DateTime? _lastTick;

  void _startLoop() {
    _lastTick = DateTime.now();
    _loopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now();
      final dt = now.difference(_lastTick!).inMicroseconds / 1000000.0;
      _lastTick = now;
      _update(dt);
    });
  }

  void _stopLoop() {
    _loopTimer?.cancel();
    _loopTimer = null;
  }

  void _update(double dt) {
    if (phase == GamePhase.input) {
      inputTimeLeft = (inputTimeLeft - dt).clamp(0, 10);
      onStateChanged?.call();
      if (inputTimeLeft <= 0) _endInput();
    } else if (phase == GamePhase.performance) {
      if (isPausing) {
        pauseTimer += dt;
        if (pauseTimer >= movePauseDuration) {
          isPausing = false;
          pauseTimer = 0;
          onStateChanged?.call();
        }
      } else {
        frameTimer += dt;
        if (frameTimer >= frameDuration) {
          frameTimer = 0;
          _advanceFrame();
        }
      }
    }
  }

  void dispose() => _stopLoop();

  void startInput() {
    phase = GamePhase.input;
    inputTimeLeft = 10.0;
    danceQueue.clear();
    performIdx = 0;
    onStateChanged?.call();
    _startLoop();
  }

  void addMove(MoveData move) {
    danceQueue.add(move);
    onStateChanged?.call();
  }

  void _endInput() {
    _stopLoop();
    phase = GamePhase.performance;
    performIdx = 0;
    currentFrame = 0;
    frameReps = 0;
    frameTimer = 0;
    isPausing = false;
    pauseTimer = 0;
    onStateChanged?.call();
    _startLoop();
  }

  void _advanceFrame() {
    if (performIdx >= danceQueue.length) {
      _endPerformance();
      return;
    }
    final move = danceQueue[performIdx];
    currentFrame++;
    if (currentFrame >= move.frames.length) {
      currentFrame = 0;
      frameReps++;
      if (frameReps >= repsPerMove) {
        frameReps = 0;
        performIdx++;
        if (performIdx >= danceQueue.length) {
          _endPerformance();
          return;
        }
        // Pause between moves
        isPausing = true;
        pauseTimer = 0;
        onStateChanged?.call();
        return;
      }
    }
    onStateChanged?.call();
  }

  void _endPerformance() {
    _stopLoop();
    phase = GamePhase.idle;
    onStateChanged?.call();
  }

  String? get currentFramePath {
    if (phase == GamePhase.performance && !isPausing && performIdx < danceQueue.length) {
      return danceQueue[performIdx].frames[currentFrame];
    }
    return null;
  }

  MoveData? get currentMove =>
      (phase == GamePhase.performance && !isPausing && performIdx < danceQueue.length)
          ? danceQueue[performIdx]
          : null;
}

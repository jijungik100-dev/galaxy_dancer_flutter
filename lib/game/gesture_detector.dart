import 'dart:math';
import '../data/move_data.dart';

class GesturePoint {
  final double x, y;
  final int timeMs;
  GesturePoint(this.x, this.y, this.timeMs);
}

class GestureRecognizer {
  static GestureCode? classify(List<GesturePoint> pts) {
    if (pts.length < 4) return null;

    final first = pts.first;
    final last = pts.last;
    final pathLen = _pathLength(pts);
    final closeD = sqrt(pow(last.x - first.x, 2) + pow(last.y - first.y, 2));

    // Circle: path is long but start ≈ end
    if (pathLen > 80 && closeD < pathLen * 0.3) return GestureCode.CIRCLE;

    final dirs = _dirSequence(pts);
    if (dirs.isEmpty) return null;

    // Compound patterns (longest first)
    if (_seqMatch(dirs, ['D', 'R', 'D'])) return GestureCode.DRD;
    if (_seqMatch(dirs, ['D', 'R'])) return GestureCode.DR;
    if (_seqMatch(dirs, ['R', 'D'])) return GestureCode.RD;

    // Simple primary direction
    return _primaryDir(pts);
  }

  static double _pathLength(List<GesturePoint> pts) {
    double l = 0;
    for (int i = 1; i < pts.length; i++) {
      l += sqrt(pow(pts[i].x - pts[i - 1].x, 2) + pow(pts[i].y - pts[i - 1].y, 2));
    }
    return l;
  }

  static List<String> _dirSequence(List<GesturePoint> pts) {
    final step = max(3, pts.length ~/ 10);
    final dirs = <String>[];
    for (int i = step; i < pts.length; i += step) {
      final dx = pts[i].x - pts[i - step].x;
      final dy = pts[i].y - pts[i - step].y;
      final mag = sqrt(dx * dx + dy * dy);
      if (mag < 6) continue;
      final d = _toDir(dx / mag, dy / mag);
      if (dirs.isEmpty || dirs.last != d) dirs.add(d);
    }
    return dirs;
  }

  static String _toDir(double nx, double ny) {
    if (nx.abs() > ny.abs() * 1.7) return nx > 0 ? 'R' : 'L';
    if (ny.abs() > nx.abs() * 1.7) return ny > 0 ? 'D' : 'U';
    return nx.abs() >= ny.abs() ? (nx > 0 ? 'R' : 'L') : (ny > 0 ? 'D' : 'U');
  }

  static GestureCode _primaryDir(List<GesturePoint> pts) {
    final dx = pts.last.x - pts.first.x;
    final dy = pts.last.y - pts.first.y;
    if (dx.abs() > dy.abs()) return dx > 0 ? GestureCode.R : GestureCode.L;
    return dy > 0 ? GestureCode.D : GestureCode.U;
  }

  static bool _seqMatch(List<String> dirs, List<String> pattern) {
    outer:
    for (int i = 0; i <= dirs.length - pattern.length; i++) {
      for (int j = 0; j < pattern.length; j++) {
        if (dirs[i + j] != pattern[j]) continue outer;
      }
      return true;
    }
    return false;
  }
}

class ComboMatcher {
  List<GestureCode> _buffer = [];
  MoveData? _pendingMatch; // matched but a longer combo might follow

  /// Returns matched MoveData if combo is confirmed, null if still waiting.
  /// Call [flushPending] when the combo timeout fires to commit any pending match.
  MoveData? feed(GestureCode gesture, List<MoveData> moves) {
    _buffer.add(gesture);

    final matched = _tryMatch(moves);
    if (matched != null) {
      // If a longer command starts with the same buffer, hold the match
      if (_hasLongerCombo(moves)) {
        _pendingMatch = matched;
        return null;
      }
      _buffer = [];
      _pendingMatch = null;
      return matched;
    }

    if (!moves.any((m) => _isPrefixOf(_buffer, m.command))) {
      // Current buffer is dead-end — return any pending match first
      final pending = _pendingMatch;
      _pendingMatch = null;
      _buffer = [gesture];

      if (pending != null) {
        // New gesture starts fresh after committing pending
        return pending;
      }

      // Retry with just the new gesture
      final single = _tryMatch(moves);
      if (single != null) {
        if (_hasLongerCombo(moves)) {
          _pendingMatch = single;
          return null;
        }
        _buffer = [];
        return single;
      }
      if (!moves.any((m) => _isPrefixOf(_buffer, m.command))) {
        _buffer = [];
      }
    }
    return null;
  }

  /// Called when combo timeout fires — commits any pending match.
  MoveData? flushPending() {
    final pending = _pendingMatch;
    _pendingMatch = null;
    _buffer = [];
    return pending;
  }

  void clear() {
    _buffer = [];
    _pendingMatch = null;
  }

  bool _hasLongerCombo(List<MoveData> moves) {
    return moves.any(
        (m) => m.command.length > _buffer.length && _isPrefixOf(_buffer, m.command));
  }

  List<GestureCode> get buffer => List.unmodifiable(_buffer);

  MoveData? _tryMatch(List<MoveData> moves) {
    return moves.cast<MoveData?>().firstWhere(
      (m) =>
          m!.command.length == _buffer.length &&
          m.command.asMap().entries.every((e) => e.value == _buffer[e.key]),
      orElse: () => null,
    );
  }

  static bool _isPrefixOf(List<GestureCode> buf, List<GestureCode> cmd) {
    if (buf.length > cmd.length) return false;
    for (int i = 0; i < buf.length; i++) {
      if (buf[i] != cmd[i]) return false;
    }
    return true;
  }
}

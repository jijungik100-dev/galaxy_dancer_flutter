import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/move_data.dart';
import '../game/galaxy_game.dart';
import '../game/gesture_detector.dart' as gd;
import 'neon_trail_painter.dart';
import 'skill_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GalaxyGame _game = GalaxyGame();
  final gd.ComboMatcher _combo = gd.ComboMatcher();
  final List<gd.GesturePoint> _currentPath = [];
  final List<TrailPoint> _trailPoints = [];

  String? _resultText;
  bool _resultOk = true;
  Timer? _resultTimer;
  Timer? _comboTimer;
  Timer? _trailTimer;

  static const _cyan = Color(0xFF00F5FF);
  static const _pink = Color(0xFFFF0090);
  static const _purple = Color(0xFF9000FF);
  static const _yellow = Color(0xFFFFE600);
  static const _bg = Color(0xFF030312);

  @override
  void initState() {
    super.initState();
    _game.onStateChanged = () => setState(() {});
    // Repaint trail continuously
    _trailTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_trailPoints.isNotEmpty) setState(() {});
    });
  }

  @override
  void dispose() {
    _game.dispose();
    _trailTimer?.cancel();
    _resultTimer?.cancel();
    _comboTimer?.cancel();
    super.dispose();
  }

  // ── Gesture input ────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    if (_game.phase != GamePhase.input) return;
    _currentPath.clear();
    _currentPath.add(gd.GesturePoint(d.localPosition.dx, d.localPosition.dy,
        DateTime.now().millisecondsSinceEpoch));
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_game.phase != GamePhase.input) return;
    final pos = d.localPosition;
    _currentPath.add(
        gd.GesturePoint(pos.dx, pos.dy, DateTime.now().millisecondsSinceEpoch));

    double speed = 0;
    if (_currentPath.length >= 2) {
      final prev = _currentPath[_currentPath.length - 2];
      speed = sqrt(pow(pos.dx - prev.x, 2) + pow(pos.dy - prev.y, 2));
    }
    _trailPoints.add(TrailPoint(pos, DateTime.now().millisecondsSinceEpoch, trailColor(speed)));

    // Remove old trail points
    final cutoff = DateTime.now().millisecondsSinceEpoch - 600;
    _trailPoints.removeWhere((p) => p.timeMs < cutoff);
  }

  void _onPanEnd(DragEndDetails _) {
    if (_game.phase != GamePhase.input) return;
    if (_currentPath.length < 5) return;

    final gesture = gd.GestureRecognizer.classify(_currentPath);
    _currentPath.clear();
    if (gesture == null) return;

    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(milliseconds: 700), () {
      final pending = _combo.flushPending();
      if (pending != null) {
        _game.addMove(pending);
        _showResult(pending.name, true);
      } else {
        _combo.clear();
      }
      setState(() {});
    });

    final matched = _combo.feed(gesture, kMoves);
    if (matched != null) {
      _game.addMove(matched);
      _showResult(matched.name, true);
    } else {
      // Show current buffer
      setState(() {});
    }
  }

  void _showResult(String text, bool ok) {
    _resultTimer?.cancel();
    setState(() {
      _resultText = ok ? '✓ $text' : '✗ $text';
      _resultOk = ok;
    });
    _resultTimer = Timer(const Duration(milliseconds: 1400), () {
      setState(() => _resultText = null);
    });
  }

  // ── Build ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          _buildHud(),
          _buildStage(),
          _buildQueue(),
          Expanded(child: _buildSwipeArea()),
          _buildBottomBar(),
        ]),
      ),
    );
  }

  // ── HUD ──────────────────────────────────────────
  Widget _buildHud() {
    final t = _game.inputTimeLeft;
    final pct = t / 10.0;
    final barColor = t <= 3
        ? const LinearGradient(colors: [Color(0xFFFF2222), Color(0xFFFF0000)])
        : const LinearGradient(colors: [_purple, _cyan]);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border(bottom: BorderSide(color: _cyan.withOpacity(0.25))),
      ),
      child: Row(children: [
        _neonText('우주대스타', 13, _cyan, letterSpacing: 3),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(children: [
              Container(height: 6, color: Colors.white12),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 100),
                widthFactor: _game.phase == GamePhase.input ? pct : 0,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: barColor,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [BoxShadow(color: _cyan.withOpacity(0.6), blurRadius: 6)],
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 38,
          child: Text(
            _game.phase == GamePhase.input ? t.toStringAsFixed(1) : '—',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: _cyan,
              fontFamily: 'monospace',
              shadows: [Shadow(color: _cyan, blurRadius: 8)],
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ]),
    );
  }

  // ── Stage ─────────────────────────────────────────
  Widget _buildStage() {
    final framePath = _game.currentFramePath;
    final imgPath = framePath ?? 'assets/images/cyborg_bboy.png';
    final moveLabel = _game.currentMove?.name;

    return Container(
      height: 210,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, 0.8),
          radius: 0.9,
          colors: [Color(0xFF00305A), _bg],
        ),
      ),
      child: Stack(children: [
        // Grid floor
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: CustomPaint(painter: _GridPainter(), size: const Size(double.infinity, 90)),
        ),
        // Floor line
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.transparent, _cyan, _pink, _cyan, Colors.transparent],
              ),
              boxShadow: [BoxShadow(color: _cyan, blurRadius: 12)],
            ),
          ),
        ),
        // Dance label
        if (moveLabel != null)
          Positioned(
            top: 10, left: 0, right: 0,
            child: Center(
              child: _neonText('♦ $moveLabel ♦', 11, _yellow, letterSpacing: 2),
            ),
          ),
        // Character
        Center(
          child: Image.asset(
            imgPath,
            width: 192, height: 192,
            filterQuality: FilterQuality.none,
            fit: BoxFit.contain,
          ),
        ),
      ]),
    );
  }

  // ── Dance Queue ────────────────────────────────────
  Widget _buildQueue() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.black45,
        border: Border.symmetric(
          horizontal: BorderSide(color: _cyan.withOpacity(0.25)),
        ),
      ),
      child: Row(children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: RotatedBox(
            quarterTurns: 3,
            child: Text('QUEUE', style: TextStyle(fontSize: 8, color: Colors.white30, letterSpacing: 1)),
          ),
        ),
        Expanded(
          child: _game.danceQueue.isEmpty
              ? const Center(
                  child: Text('— 입력 대기 —',
                      style: TextStyle(fontSize: 10, color: Colors.white24, letterSpacing: 1)))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  itemCount: _game.danceQueue.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final move = _game.danceQueue[i];
                    final isPlaying = _game.phase == GamePhase.performance && i == _game.performIdx;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: isPlaying ? _pink : _cyan.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                        color: isPlaying ? _pink.withOpacity(0.12) : _cyan.withOpacity(0.05),
                        boxShadow: isPlaying ? [BoxShadow(color: _pink, blurRadius: 8)] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(move.frames[0], width: 20, height: 20, filterQuality: FilterQuality.none),
                          Text(move.name, style: const TextStyle(fontSize: 7, color: _cyan), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  // ── Swipe Area ─────────────────────────────────────
  Widget _buildSwipeArea() {
    return Stack(children: [
      // Background
      Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(colors: [Color(0xFF0A0A28), _bg]),
        ),
      ),
      // Neon trail canvas
      GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: NeonTrailPainter(List.from(_trailPoints)),
          child: const SizedBox.expand(),
        ),
      ),
      // Hint (input phase only)
      if (_game.phase == GamePhase.input)
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('← ↑ ↓ →', style: TextStyle(fontSize: 22, color: Color(0x5500F5FF), letterSpacing: 8)),
              SizedBox(height: 6),
              Text('SWIPE TO DANCE', style: TextStyle(fontSize: 10, color: Color(0x5500F5FF), letterSpacing: 3)),
            ],
          ),
        ),
      // START overlay (idle / performance-done)
      if (_game.phase == GamePhase.idle)
        Center(
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StartButton(onTap: () {
                    _comboTimer?.cancel();
                    _combo.clear();
                    setState(() {});
                    _game.startInput();
                  }),
                  const SizedBox(height: 12),
                  const Text('탭하여 10초 입력 시작',
                      style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 2)),
                ],
              ),
            ),
          ),
        ),
      // Gesture result
      if (_resultText != null)
        Positioned(
          top: 14, left: 0, right: 0,
          child: Center(
            child: Text(
              _resultText!,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold,
                color: _resultOk ? _cyan : const Color(0xFFFF4444),
                shadows: [Shadow(color: _resultOk ? _cyan : const Color(0xFFFF4444), blurRadius: 14)],
              ),
            ),
          ),
        ),
      // Combo buffer display
      if (_combo.buffer.isNotEmpty)
        Positioned(
          bottom: 14, left: 0, right: 0,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _combo.buffer.map((g) => _comboBadge(_gestureSymbol(g))).toList(),
            ),
          ),
        ),
    ]);
  }

  Widget _comboBadge(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: _cyan.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(3),
        color: _cyan.withOpacity(0.08),
        boxShadow: [BoxShadow(color: _cyan.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: _cyan,
              shadows: [Shadow(color: _cyan, blurRadius: 10)])),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border(top: BorderSide(color: _cyan.withOpacity(0.25))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _openSkillPanel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: _cyan),
                borderRadius: BorderRadius.circular(4),
                color: _cyan.withOpacity(0.04),
              ),
              child: const Text('📋 스킬 목록',
                  style: TextStyle(fontSize: 12, color: _cyan, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  void _openSkillPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SkillPanel(),
    );
  }

  // ── Helpers ────────────────────────────────────────
  String _gestureSymbol(GestureCode g) {
    return switch (g) {
      GestureCode.R => 'ㅡ',
      GestureCode.D => 'ㅣ',
      GestureCode.DR => 'ㄴ',
      GestureCode.RD => 'ㄱ',
      GestureCode.DRD => 'ㄹ',
      GestureCode.CIRCLE => '○',
      GestureCode.L => '←',
      GestureCode.U => '↑',
    };
  }

  Widget _neonText(String s, double size, Color color, {double letterSpacing = 0}) {
    return Text(s,
        style: TextStyle(
          fontSize: size, fontWeight: FontWeight.bold,
          color: color, letterSpacing: letterSpacing,
          shadows: [Shadow(color: color, blurRadius: 8)],
        ));
  }
}

// ── Start Button ──────────────────────────────────────
class _StartButton extends StatefulWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});
  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _glow = Tween(begin: 20.0, end: 50.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00F5FF), Color(0xFF9000FF)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00F5FF).withOpacity(0.7), blurRadius: _glow.value),
            ],
          ),
          child: const Text('▶  DANCE',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold,
                  letterSpacing: 5, color: Color(0xFF030312))),
        ),
      ),
    );
  }
}

// ── Grid Floor Painter ────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.1)
      ..strokeWidth = 1;
    // Vertical lines
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

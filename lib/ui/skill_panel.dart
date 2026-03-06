import 'package:flutter/material.dart';
import '../data/move_data.dart';

class SkillPanel extends StatelessWidget {
  const SkillPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.76,
      decoration: BoxDecoration(
        color: const Color(0xFF080820),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: const Color(0xFF00F5FF), width: 2),
          left: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.25)),
          right: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.25)),
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00F5FF).withOpacity(0.12), blurRadius: 40, spreadRadius: -10),
        ],
      ),
      child: Column(
        children: [
          _header(context),
          Expanded(child: _list()),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.25))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '댄스 스킬',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold,
              color: const Color(0xFF00F5FF),
              shadows: [Shadow(color: const Color(0xFF00F5FF), blurRadius: 8)],
              letterSpacing: 2,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.3)),
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    final grouped = <int, List<MoveData>>{};
    for (final m in kMoves) {
      (grouped[m.diff] ??= []).add(m);
    }
    final diffLabels = {
      1: '★☆☆☆☆  기초',
      2: '★★☆☆☆  초급',
      3: '★★★☆☆  숙련',
      4: '★★★★☆  고급',
      5: '★★★★★  마스터',
    };
    final diffColors = {
      1: const Color(0xFF00FF88),
      2: const Color(0xFF88FF00),
      3: const Color(0xFF00F5FF),
      4: const Color(0xFFFF0090),
      5: const Color(0xFF9000FF),
    };

    final items = <Widget>[];
    for (int diff = 1; diff <= 5; diff++) {
      final moves = grouped[diff];
      if (moves == null) continue;
      items.add(_diffHeader(diffLabels[diff]!));
      for (final move in moves) {
        items.add(_skillItem(move, diffColors[diff]!));
      }
    }

    return ListView(padding: const EdgeInsets.all(8), children: items);
  }

  Widget _diffHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 2)),
          const Divider(color: Colors.white12, height: 6),
        ],
      ),
    );
  }

  Widget _skillItem(MoveData move, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: accent, width: 3),
          right: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.12)),
          top: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.12)),
          bottom: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.12)),
        ),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
        color: const Color(0xFF00F5FF).withOpacity(0.04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 아이콘 ──
          Container(
            width: 72, height: 72,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.circular(8),
              color: Colors.black38,
              boxShadow: [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 8)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset(
                move.icon,
                filterQuality: FilterQuality.none,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // ── 스킬명 + 설명 ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    move.name,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    move.nameEn,
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    move.desc,
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75), height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ── 스탯 / 커맨드 ──
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(move.stars, style: const TextStyle(fontSize: 10, color: Color(0xFFFFE600))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (int i = 0; i < move.cmdDisplay.length; i++) ...[
                      if (i > 0) const Text('+', style: TextStyle(fontSize: 9, color: Colors.white30)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFF0090).withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFFFF0090).withOpacity(0.10),
                        ),
                        child: Text(
                          move.cmdDisplay[i],
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFF0090)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text('⚔ ATK ${move.attack}', style: const TextStyle(fontSize: 10, color: Color(0xFFFFCC00))),
                if (move.buff != null) ...[
                  const SizedBox(height: 2),
                  Text('⚡ ${move.buff!.label}', style: const TextStyle(fontSize: 10, color: Color(0xFFFFE600))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

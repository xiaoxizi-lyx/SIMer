import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/sim_card.dart';
import '../models/tag.dart';
import 'sim_card_front.dart';
import 'sim_card_back.dart';

/// 3D翻转卡片组件
///
/// 包装前后两面，提供 Y 轴 180° 翻转动画（500ms, easeInOut）
class SimCardFlip extends StatefulWidget {
  final SimCard simCard;
  final List<Tag> tags;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onMarkAsUsed;

  const SimCardFlip({
    super.key,
    required this.simCard,
    this.tags = const [],
    this.onEdit,
    this.onArchive,
    this.onMarkAsUsed,
  });

  @override
  State<SimCardFlip> createState() => SimCardFlipState();
}

class SimCardFlipState extends State<SimCardFlip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  bool get isFlipped => _isFlipped;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isFlipped = !_isFlipped;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isFront = _animation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 透视
              ..rotateY(angle),
            child: isFront
                ? SimCardFront(
                    simCard: widget.simCard,
                    tags: widget.tags,
                    onMarkAsUsed: widget.onMarkAsUsed,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: SimCardBack(
                      simCard: widget.simCard,
                      tags: widget.tags,
                      onEdit: widget.onEdit,
                      onArchive: widget.onArchive,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

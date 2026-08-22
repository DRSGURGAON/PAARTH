import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps [child] and plays a quick horizontal shake whenever
/// [shakeSignal] changes value — the caller bumps a counter (e.g. on
/// every wrong answer) rather than this widget exposing an imperative
/// "shake now" method, so a shake triggered mid-rebuild is never lost.
class ShakeWidget extends StatefulWidget {
  const ShakeWidget({required this.child, required this.shakeSignal, super.key});

  final Widget child;
  final int shakeSignal;

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

@visibleForTesting
class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _offset = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
  ]).animate(_controller);

  @visibleForTesting
  Animation<double> get offset => _offset;

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeSignal != oldWidget.shakeSignal) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) =>
          Transform.translate(offset: Offset(_offset.value, 0), child: child),
      child: widget.child,
    );
  }
}

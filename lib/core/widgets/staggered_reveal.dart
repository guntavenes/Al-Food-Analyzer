import 'package:flutter/material.dart';

class StaggeredReveal extends StatefulWidget {
  const StaggeredReveal({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.055),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSlide(
      offset: _visible || reduceMotion ? Offset.zero : widget.offset,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible || reduceMotion ? 1 : 0,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

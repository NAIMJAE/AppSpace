import 'package:flutter/material.dart';

class SlideSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final AxisDirection direction;

  const SlideSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.direction = AxisDirection.left,
  });

  Offset _getOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final beginOffset = _getOffset(direction);
        final offsetAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      child: child,
    );
  }
}

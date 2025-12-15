import 'package:flutter/material.dart';

class RippleWrapper extends StatefulWidget {
  final Widget child;
  const RippleWrapper({super.key, required this.child});

  @override
  State<RippleWrapper> createState() => _RippleWrapperState();
}

class _RippleWrapperState extends State<RippleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, // fixed space so FAB never moves
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              final t = _controller.value;

              return Transform.scale(
                scale: 1 + (t * 0.6), // ripple grows outward
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity((1 - t) * 0.25),
                  ),
                ),
              );
            },
          ),

          // FAB stays fixed, never moves
          widget.child,
        ],
      ),
    );
  }
}

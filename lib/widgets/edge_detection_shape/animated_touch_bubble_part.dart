import 'package:flutter/material.dart';

class AnimatedTouchBubblePart extends StatelessWidget {
  const AnimatedTouchBubblePart({
    Key? key,
    required this.dragging,
    required this.size,
    required this.edgeColor,
  }) : super(key: key);

  final bool dragging;
  final double size;
  final Color edgeColor;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: dragging ? 0 : size / 2,
        height: dragging ? 0 : size / 2,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: edgeColor),
          borderRadius: dragging
              ? BorderRadius.circular(size)
              : BorderRadius.circular(size / 4),
        ),
      ),
    );
  }
}

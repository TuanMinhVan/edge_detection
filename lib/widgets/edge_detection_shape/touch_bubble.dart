import 'package:flutter/material.dart';

import 'animated_touch_bubble_part.dart';

class TouchBubble extends StatefulWidget {
  const TouchBubble({
    Key? key,
    required this.size,
    required this.onDrag,
    required this.onDragFinished,
    required this.edgeColor,
  }) : super(key: key);

  final double size;
  final Function onDrag;
  final Function onDragFinished;
  final Color edgeColor;
  @override
  State<TouchBubble> createState() => _TouchBubbleState();
}

class _TouchBubbleState extends State<TouchBubble> {
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _startDragging,
      onPanUpdate: _drag,
      onPanCancel: _cancelDragging,
      onPanEnd: (_) => _cancelDragging(),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedTouchBubblePart(
          dragging: dragging,
          size: widget.size,
          edgeColor: widget.edgeColor,
        ),
      ),
    );
  }

  void _startDragging(DragStartDetails data) {
    setState(() {
      dragging = true;
    });
    widget.onDrag(
      data.localPosition - Offset(widget.size / 2, widget.size / 2),
    );
  }

  void _cancelDragging() {
    setState(() {
      dragging = false;
    });
    widget.onDragFinished.call();
  }

  void _drag(DragUpdateDetails data) {
    if (!dragging) {
      return;
    }
    widget.onDrag(data.delta);
  }
}

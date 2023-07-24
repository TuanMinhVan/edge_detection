import 'dart:math';
import 'package:flutter/material.dart' hide Magnifier;
import 'package:gmo_edge_detection/gmo_edge_detection.dart';

import '../image_preview.dart';
import 'edge_painter.dart';
import 'magnifier.dart';
import 'touch_bubble.dart';

class EdgeDetectionShape extends StatefulWidget {
  const EdgeDetectionShape({
    Key? key,
    required this.renderedImageSize,
    required this.originalImageSize,
    this.edgeDetectionResult,
    required this.onEdgeDetectionResultCallBack,
    required this.padding,
    this.edgeColor = Colors.black,
  }) : super(key: key);
  final EdgeInsets padding;
  final Size renderedImageSize;
  final Size originalImageSize;
  final EdgeDetectionResult? edgeDetectionResult;
  final OnEdgeDetectionResultCallBack onEdgeDetectionResultCallBack;
  final Color edgeColor;
  @override
  State<EdgeDetectionShape> createState() => _EdgeDetectionShapeState();
}

class _EdgeDetectionShapeState extends State<EdgeDetectionShape> {
  late double edgeDraggerSize;

  late EdgeDetectionResult edgeDetectionResult;
  List<Offset> points = [];

  double renderedImageWidth = 0;
  double renderedImageHeight = 0;
  double top = 10;
  double left = 10;

  Offset? currentDragPosition;
  late double padding;
  @override
  void didChangeDependencies() {
    double shortestSide = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    edgeDraggerSize = shortestSide / 9;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    padding = widget.padding.vertical / 2;
    edgeDetectionResult = widget.edgeDetectionResult!;
    _calculateDimensionValues();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Magnifier(
        visible: currentDragPosition != null,
        position: currentDragPosition,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (currentDragPosition == null)
              _getTouchBubbles(widget.onEdgeDetectionResultCallBack),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomPaint(
                painter: EdgePainter(
                  points: points,
                  color: widget.edgeColor,
                ),
              ),
            ),
            IgnorePointer(
              ignoring: currentDragPosition != null,
              child: _getTouchBubbles(widget.onEdgeDetectionResultCallBack),
            ),
          ],
        ));
  }

  void _calculateDimensionValues() {
    top = 0.0;
    left = 0.0;

    double widthFactor =
        widget.renderedImageSize.width / widget.originalImageSize.width;
    double heightFactor =
        widget.renderedImageSize.height / widget.originalImageSize.height;
    double sizeFactor = min(widthFactor, heightFactor);

    renderedImageHeight = widget.originalImageSize.height * sizeFactor;
    top = ((widget.renderedImageSize.height - renderedImageHeight) / 2);

    renderedImageWidth = widget.originalImageSize.width * sizeFactor;
    left = ((widget.renderedImageSize.width - renderedImageWidth) / 2);
  }

  Offset _getNewPositionAfterDrag(
      Offset position, double renderedImageWidth, double renderedImageHeight) {
    return Offset(
        position.dx / renderedImageWidth, position.dy / renderedImageHeight);
  }

  Offset _clampOffset(Offset givenOffset) {
    double absoluteX = givenOffset.dx * renderedImageWidth;
    double absoluteY = givenOffset.dy * renderedImageHeight;

    return Offset(absoluteX.clamp(0.0, renderedImageWidth) / renderedImageWidth,
        absoluteY.clamp(0.0, renderedImageHeight) / renderedImageHeight);
  }

  Widget _getTouchBubbles(OnEdgeDetectionResultCallBack callBack) {
    points = [
      Offset(
        left + edgeDetectionResult.topLeft.dx * renderedImageWidth,
        top + edgeDetectionResult.topLeft.dy * renderedImageHeight,
      ),
      Offset(
        left + edgeDetectionResult.topRight.dx * renderedImageWidth,
        top + edgeDetectionResult.topRight.dy * renderedImageHeight,
      ),
      Offset(
        left + edgeDetectionResult.bottomRight.dx * renderedImageWidth,
        top + (edgeDetectionResult.bottomRight.dy * renderedImageHeight),
      ),
      Offset(
        left + edgeDetectionResult.bottomLeft.dx * renderedImageWidth,
        top + edgeDetectionResult.bottomLeft.dy * renderedImageHeight,
      ),
      Offset(
        left + edgeDetectionResult.topLeft.dx * renderedImageWidth,
        top + edgeDetectionResult.topLeft.dy * renderedImageHeight,
      ),
    ];

    void onDragFinished() {
      currentDragPosition = null;
      setState(() {});
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
            left: points[0].dx - (edgeDraggerSize / 2) + padding,
            top: points[0].dy - (edgeDraggerSize / 2) + padding,
            child: TouchBubble(
                edgeColor: widget.edgeColor,
                size: edgeDraggerSize,
                onDrag: (position) {
                  setState(() {
                    currentDragPosition = Offset(points[0].dx, points[0].dy);
                    Offset newTopLeft = _getNewPositionAfterDrag(
                        position, renderedImageWidth, renderedImageHeight);
                    edgeDetectionResult.topLeft =
                        _clampOffset(edgeDetectionResult.topLeft + newTopLeft);
                    widget.onEdgeDetectionResultCallBack
                        .call(edgeDetectionResult);
                  });
                },
                onDragFinished: onDragFinished)),
        Positioned(
          left: points[1].dx - (edgeDraggerSize / 2) + padding,
          top: points[1].dy - (edgeDraggerSize / 2) + padding,
          child: TouchBubble(
              edgeColor: widget.edgeColor,
              size: edgeDraggerSize,
              onDrag: (position) {
                setState(() {
                  Offset newTopRight = _getNewPositionAfterDrag(
                      position, renderedImageWidth, renderedImageHeight);
                  edgeDetectionResult.topRight =
                      _clampOffset(edgeDetectionResult.topRight + newTopRight);
                  currentDragPosition = Offset(points[1].dx, points[1].dy);
                  widget.onEdgeDetectionResultCallBack
                      .call(edgeDetectionResult);
                });
              },
              onDragFinished: onDragFinished),
        ),
        Positioned(
          left: points[2].dx - (edgeDraggerSize / 2) + padding,
          top: points[2].dy - (edgeDraggerSize / 2) + padding,
          child: TouchBubble(
              edgeColor: widget.edgeColor,
              size: edgeDraggerSize,
              onDrag: (position) {
                setState(() {
                  Offset newBottomRight = _getNewPositionAfterDrag(
                      position, renderedImageWidth, renderedImageHeight);
                  edgeDetectionResult.bottomRight = _clampOffset(
                      edgeDetectionResult.bottomRight + newBottomRight);
                  currentDragPosition = Offset(points[2].dx, points[2].dy);
                  widget.onEdgeDetectionResultCallBack
                      .call(edgeDetectionResult);
                });
              },
              onDragFinished: onDragFinished),
        ),
        Positioned(
          left: points[3].dx - (edgeDraggerSize / 2) + padding,
          top: points[3].dy - (edgeDraggerSize / 2) + padding,
          child: TouchBubble(
              edgeColor: widget.edgeColor,
              size: edgeDraggerSize,
              onDrag: (position) {
                setState(() {
                  Offset newBottomLeft = _getNewPositionAfterDrag(
                      position, renderedImageWidth, renderedImageHeight);
                  edgeDetectionResult.bottomLeft = _clampOffset(
                      edgeDetectionResult.bottomLeft + newBottomLeft);
                  currentDragPosition = Offset(points[3].dx, points[3].dy);
                  widget.onEdgeDetectionResultCallBack
                      .call(edgeDetectionResult);
                });
              },
              onDragFinished: onDragFinished),
        ),
      ],
    );
  }
}

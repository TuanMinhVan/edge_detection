import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gmo_edge_detection/gmo_edge_detection.dart';

import 'edge_detection_shape/edge_detection_shape.dart';

typedef OnEdgeDetectionResultCallBack = void Function(
    EdgeDetectionResult result);

class ImagePreviewWidget extends StatefulWidget {
  const ImagePreviewWidget({
    Key? key,
    required this.imagePath,
    this.edgeDetectionResult,
    this.loadingWidget,
    this.onEdgeDetectionResultCallBack,
    this.padding = const EdgeInsets.all(20.0),
    this.edgeColor = Colors.black,
  }) : super(key: key);

  final String imagePath;
  final Widget? loadingWidget;
  final EdgeDetectionResult? edgeDetectionResult;
  final OnEdgeDetectionResultCallBack? onEdgeDetectionResultCallBack;
  final EdgeInsets padding;
  final Color edgeColor;
  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  GlobalKey imageWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext mainContext) {
    return Center(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          widget.loadingWidget ?? const Center(child: Text('Loading ...')),
          Padding(
            padding: widget.padding,
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              key: imageWidgetKey,
            ),
          ),
          FutureBuilder<ui.Image>(
            future: loadUiImage(widget.imagePath),
            builder: (_, AsyncSnapshot<ui.Image> snapshot) {
              return _getEdgePaint(snapshot, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _getEdgePaint(
      AsyncSnapshot<ui.Image> imageSnapshot, BuildContext context) {
    if (imageSnapshot.connectionState == ConnectionState.waiting) {
      return Container();
    }

    if (imageSnapshot.hasError) return Text('Error: ${imageSnapshot.error}');

    if (widget.edgeDetectionResult == null) return Container();

    final keyContext = imageWidgetKey.currentContext;

    if (keyContext == null) {
      return Container();
    }

    final box = keyContext.findRenderObject() as RenderBox;

    return EdgeDetectionShape(
      edgeColor: widget.edgeColor,
      padding: widget.padding,
      originalImageSize: Size(
        imageSnapshot.data?.width.toDouble() ?? 0,
        imageSnapshot.data?.height.toDouble() ?? 0,
      ),
      renderedImageSize: Size(box.size.width, box.size.height),
      edgeDetectionResult: widget.edgeDetectionResult,
      onEdgeDetectionResultCallBack: (res) {
        widget.onEdgeDetectionResultCallBack?.call(res);
      },
    );
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final Uint8List data = await File(imageAssetPath).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image image) {
      return completer.complete(image);
    });
    return completer.future;
  }
}

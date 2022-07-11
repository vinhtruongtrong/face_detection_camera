/*
 * @Author: vinhtruongtrong 
 * @Date: 2022-07-09 10:18:47 
 * @Last Modified by: vinhtruongtrong
 * @Last Modified time: 2022-07-11 10:14:00
 */

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_detection_camera/src/res/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:face_detection_camera/src/res/extensions.dart';

class LiveCameraView extends StatefulWidget {
  const LiveCameraView(
      {Key? key,
      required this.camera,
      required this.customPaint,
      required this.onImage,
      required this.onCapture,
      this.preset,
      this.flashMode})
      : super(key: key);

  final CameraDescription camera;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final void Function(File? image) onCapture;
  final ImageResolution? preset;
  final CameraFlashMode? flashMode;

  @override
  LiveCameraViewState createState() => LiveCameraViewState();
}

class LiveCameraViewState extends State<LiveCameraView> {
  CameraDescription get camera => widget.camera;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),
          if (widget.customPaint != null) widget.customPaint!,
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    _controller = CameraController(
      camera,
      widget.preset?.toResolutionPreset() ?? ResolutionPreset.high,
      enableAudio: false,
    );

    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.setFlashMode(
        widget.flashMode?.toFlashMode() ?? FlashMode.auto,
      );

      // _controller?.set
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    try {
      await _controller?.stopImageStream();
    } on CameraException catch (e) {
      debugPrint('Error: ${e.code}\n${e.description}');
    }
    await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }

  void takePicture() async {
    Future<XFile?> _takePicture() async {
      final CameraController? cameraController = _controller;
      if (cameraController == null || !cameraController.value.isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: select a camera first.')));
        return null;
      }

      if (cameraController.value.isTakingPicture) {
        // A capture is already pending, do nothing.
        return null;
      }

      try {
        XFile file = await cameraController.takePicture();
        return file;
      } on CameraException catch (e) {
        debugPrint(e.toString());
        return null;
      }
    }

    final CameraController? cameraController = _controller;
    try {
      cameraController!.stopImageStream().whenComplete(() async {
        await Future.delayed(const Duration(milliseconds: 500));
        _takePicture().then((XFile? file) {
          /// Return image callback
          widget.onCapture(File(file!.path));

          /// Resume image stream after 2 seconds of capture

          Future.delayed(const Duration(seconds: 2)).whenComplete(() {
            if (mounted && cameraController.value.isInitialized) {
              try {
                _controller?.startImageStream(_processCameraImage);
              } catch (e) {
                debugPrint(e.toString());
              }
            }
          });
        });
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

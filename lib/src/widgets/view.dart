/*
 * @Author: vinhtruongtrong 
 * @Date: 2022-07-09 10:47:13 
 * @Last Modified by: vinhtruongtrong
 * @Last Modified time: 2022-07-11 10:15:54
 */

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_detection_camera/src/res/results.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'painters/face_detector_painter.dart';
import 'view.live_camera_view.dart';
import '../res/enums.dart';
import '../utils/utils.dart';
import '../res/extensions.dart';

class FaceDetectionCamera extends StatefulWidget {
  const FaceDetectionCamera({
    Key? key,
    this.faceDetectionResult,
    this.autoCapture = false,
    this.direction,
    this.preset,
    this.flashMode,
    this.onCapture,
  }) : super(key: key);

  final FaceDetectionResult? faceDetectionResult;
  final bool autoCapture;
  final Function(File? image)? onCapture;
  final CameraLens? direction;
  final ImageResolution? preset;
  final CameraFlashMode? flashMode;

  @override
  FaceDetectionCameraState createState() => FaceDetectionCameraState();
}

class FaceDetectionCameraState extends State<FaceDetectionCamera> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  final GlobalKey<LiveCameraViewState> _cameraViewKey =
      GlobalKey<LiveCameraViewState>();

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiveCameraView(
      key: _cameraViewKey,
      camera: FaceDetectionCameraUtils.cameras.firstWhere(
        (element) =>
            element.lensDirection ==
            (widget.direction?.toCameraLensDirection() ??
                CameraLensDirection.front),
      ),
      flashMode: widget.flashMode,
      preset: widget.preset,
      customPaint: _customPaint,
      onCapture: (file) {},
      onImage: processImage,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    try {
      final faces = await _faceDetector.processImage(inputImage);
      final inputImagaData = inputImage.inputImageData;
      if (inputImagaData != null && faces.isNotEmpty) {
        final detectedFace = FaceDetectionCameraUtils.extractFace(faces);
        final painter = FaceDetectorPainter(
          detectedFace,
          inputImagaData.size,
          inputImagaData.imageRotation,
        );

        final face = detectedFace.face;
        widget.faceDetectionResult?.call(
          face.leftEyeOpenProbability,
          face.rightEyeOpenProbability,
          face.smilingProbability,
          detectedFace.wellPositioned,
          face.trackingId,
        );

        if (detectedFace.wellPositioned && widget.autoCapture) {
          _cameraViewKey.currentState?.takePicture();
        }
        _customPaint = CustomPaint(painter: painter);
      } else {
        _customPaint = null;
        if (faces.isEmpty) {
          widget.faceDetectionResult?.call(0, 0, 0, false, -99);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

import 'dart:math';

import 'package:face_detection_camera/src/models/detected_face.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.detectedFace, this.absoluteImageSize, this.rotation);

  final DetectedFace detectedFace;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint;
    final face = detectedFace.face;
    if (face.headEulerAngleY! > 10 || face.headEulerAngleY! < -10) {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.yellow.withOpacity(.5);
    } else {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.green.withOpacity(.5);
    }

    canvas.drawRect(
      Rect.fromLTRB(
        translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
        translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
        translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
        translateY(face.boundingBox.bottom, rotation, size, absoluteImageSize),
      ),
      paint
        ..color = face.headEulerAngleY! > 10 || face.headEulerAngleY! < -10
            ? const Color.fromARGB(255, 204, 189, 20).withOpacity(.5)
            : const Color.fromARGB(255, 41, 175, 126).withOpacity(.5),
    );

    void paintContour(FaceContourType type) {
      final faceContour = face.contours[type];
      if (faceContour?.points != null) {
        for (final Point point in faceContour!.points) {
          canvas.drawCircle(
              Offset(
                translateX(
                    point.x.toDouble(), rotation, size, absoluteImageSize),
                translateY(
                    point.y.toDouble(), rotation, size, absoluteImageSize),
              ),
              1,
              paint);
        }
      }
    }

    paintContour(FaceContourType.face);
    paintContour(FaceContourType.leftEyebrowTop);
    paintContour(FaceContourType.leftEyebrowBottom);
    paintContour(FaceContourType.rightEyebrowTop);
    paintContour(FaceContourType.rightEyebrowBottom);
    paintContour(FaceContourType.leftEye);
    paintContour(FaceContourType.rightEye);
    paintContour(FaceContourType.upperLipTop);
    paintContour(FaceContourType.upperLipBottom);
    paintContour(FaceContourType.lowerLipTop);
    paintContour(FaceContourType.lowerLipBottom);
    paintContour(FaceContourType.noseBridge);
    paintContour(FaceContourType.noseBottom);
    paintContour(FaceContourType.leftCheek);
    paintContour(FaceContourType.rightCheek);
  }

  @override
  bool shouldRepaint(covariant FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.detectedFace != detectedFace;
  }
}

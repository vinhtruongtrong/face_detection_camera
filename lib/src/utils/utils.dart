/*
 * @Author: vinhtruongtrong 
 * @Date: 2022-07-11 09:25:31 
 * @Last Modified by: vinhtruongtrong
 * @Last Modified time: 2022-07-11 10:13:21
 */
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/detected_face.dart';

class FaceDetectionCameraUtils {
  static List<CameraDescription> cameras = [];
  static Future<void> initialize() async {
    cameras = await availableCameras();
  }

  static DetectedFace extractFace(List<Face> faces) {
    bool wellPositioned = faces.isNotEmpty;
    Face? detectedFace;

    for (Face face in faces) {
      detectedFace = face;

      // Head is rotated to the right rotY degrees
      if (face.headEulerAngleY! > 2 || face.headEulerAngleY! < -2) {
        wellPositioned = false;
      }

      // Head is tilted sideways rotZ degrees
      if (face.headEulerAngleZ! > 2 || face.headEulerAngleZ! < -2) {
        wellPositioned = false;
      }

      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
      final FaceLandmark? rightEar = face.landmarks[FaceLandmarkType.rightEar];
      if (leftEar != null && rightEar != null) {
        if (leftEar.position.y < 0 ||
            leftEar.position.x < 0 ||
            rightEar.position.y < 0 ||
            rightEar.position.x < 0) {
          wellPositioned = false;
        }
      }

      if (face.leftEyeOpenProbability != null) {
        if (face.leftEyeOpenProbability! < 0.5) {
          wellPositioned = false;
        }
      }

      if (face.rightEyeOpenProbability != null) {
        if (face.rightEyeOpenProbability! < 0.5) {
          wellPositioned = false;
        }
      }
    }

    return DetectedFace(wellPositioned: wellPositioned, face: detectedFace!);
  }
}

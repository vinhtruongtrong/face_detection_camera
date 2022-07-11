///
/// [leftEyeOpenProbability] is the probability that the left eye is open.
///
/// [rightEyeOpenProbability] is the probability that the right eye is open.
///
/// [smilingProbability] is the probability that the face is smiling.
///
/// [wellPositioned] is true if the face is center.
///
/// [trackingId] is the tracking id of the face
///  will change when your face not in screen.
///
typedef FaceDetectionResult = void Function(
  double? leftEyeOpenProbability,
  double? rightEyeOpenProbability,
  double? smilingProbability,
  bool? wellPositioned,
  int? trackingId,
);

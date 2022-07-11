import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import 'enums.dart';

extension ImageResolutionX on ImageResolution {
  ResolutionPreset toResolutionPreset() {
    switch (this) {
      case ImageResolution.low:
        return ResolutionPreset.low;
      case ImageResolution.medium:
        return ResolutionPreset.medium;
      case ImageResolution.high:
        return ResolutionPreset.high;
      case ImageResolution.veryHigh:
        return ResolutionPreset.veryHigh;
      case ImageResolution.ultraHigh:
        return ResolutionPreset.ultraHigh;
      case ImageResolution.max:
        return ResolutionPreset.max;
    }
  }
}

extension CameraLensX on CameraLens {
  CameraLensDirection? toCameraLensDirection() {
    switch (this) {
      case CameraLens.front:
        return CameraLensDirection.front;
      case CameraLens.back:
        return CameraLensDirection.back;
      case CameraLens.external:
        return CameraLensDirection.external;
      default:
        return null;
    }
  }
}

extension CameraLensDirectionX on CameraLensDirection {
  CameraLens? toCameraLens() {
    switch (this) {
      case CameraLensDirection.front:
        return CameraLens.front;
      case CameraLensDirection.back:
        return CameraLens.back;
      case CameraLensDirection.external:
        return CameraLens.external;
      default:
        return null;
    }
  }
}

extension CameraFlashModeX on CameraFlashMode {
  FlashMode toFlashMode() {
    switch (this) {
      case CameraFlashMode.off:
        return FlashMode.off;
      case CameraFlashMode.auto:
        return FlashMode.auto;
      case CameraFlashMode.always:
        return FlashMode.always;
    }
  }
}

extension CameraOrientationX on CameraOrientation {
  DeviceOrientation? toDeviceOrientation() {
    switch (this) {
      case CameraOrientation.portraitUp:
        return DeviceOrientation.portraitUp;
      case CameraOrientation.landscapeLeft:
        return DeviceOrientation.landscapeLeft;
      case CameraOrientation.portraitDown:
        return DeviceOrientation.portraitDown;
      case CameraOrientation.landscapeRight:
        return DeviceOrientation.landscapeRight;
      default:
        return null;
    }
  }
}

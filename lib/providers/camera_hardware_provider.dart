import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as image;

enum CameraType { rear, front }

enum CameraHardwareState {
  uninitialized,
  busy,
  failed,
  ready,
}

extension FlashModeIcon on FlashMode {
  IconData toIcon() {
    switch (this) {
      case FlashMode.off:
        return Icons.flash_off;

      case FlashMode.auto:
        return Icons.flash_auto;

      case FlashMode.always:
        return Icons.flash_on;

      case FlashMode.torch:
        return Icons.flashlight_on_rounded;

      default:
        return Icons.flash_on;
    }
  }
}

class CameraHardwareProvider extends ChangeNotifier {
  /// Camera availability check
  CameraHardwareState _state = CameraHardwareState.uninitialized;
  CameraHardwareState get state => _state;

  // Exception handler
  CameraException? _exception;
  CameraException? get exception => _exception;

  // Current camera controller
  CameraController? _currentController;
  CameraController? get currentController => _currentController;

  CameraType _cameraType = CameraType.front;
  CameraType get cameraType => _cameraType;

  FlashMode _currentFlashMode = FlashMode.auto;
  FlashMode get flashMode => _currentFlashMode;
  set flashMode(FlashMode flashMode) {
    // Set flash mode
    currentController?.setFlashMode(flashMode);
    _currentFlashMode = flashMode;
    notifyListeners();
  }

  // Camera descriptions
  late final Map<CameraType, CameraDescription> _descriptors;

  /// First time initialization of CameraHardware
  void initialize() async {
    if (_state == CameraHardwareState.uninitialized) {
      try {
        _state = CameraHardwareState.busy; // Change state to busy
        final cameras = await availableCameras(); // Get cameras
        log("$runtimeType: Camera information fetched, ${cameras.length} were found\nDescription: ${cameras.toString()}");
        // Store descriptors
        _descriptors = {
          CameraType.front: cameras.firstWhere((element) =>
              (element.lensDirection == CameraLensDirection.front)),
          CameraType.rear: cameras.firstWhere(
              (element) => (element.lensDirection == CameraLensDirection.back)),
        };
        // Create new controller and set new state
        _createController();
        await _currentController!.initialize();
        flashMode = FlashMode.auto;
        _state = CameraHardwareState.ready;
      } on CameraException catch (e) {
        // Save exception
        _exception = e;
        _state = CameraHardwareState.failed;
        rethrow;
      } finally {
        flashMode =
            (cameraType == CameraType.front ? FlashMode.off : FlashMode.auto);
        notifyListeners(); // Notify all camera listeners
      }
    }
  }

  /// Create a new [CameraController] based on current [CameraType]
  void _createController() {
    _currentController =
        CameraController(_descriptors[_cameraType]!, ResolutionPreset.max);
  }

  /// Assign camera to rear or front
  void changeCamera(CameraType cameraType) async {
    try {
      _state = CameraHardwareState.busy; // Change state to busy
      await _currentController!.dispose(); // Dispose old controller
      _cameraType = cameraType; // Assign new camera
      _createController(); // Create the new controller
      await _currentController!.initialize(); // Initialize new controller
      _state = CameraHardwareState.ready;
    } on CameraException catch (e) {
      // Save exception
      _exception = e;
      _state = CameraHardwareState.failed;
      rethrow;
    } finally {
      flashMode =
          (cameraType == CameraType.front ? FlashMode.off : FlashMode.auto);
      notifyListeners();
    }
  }

  void flipCamera() {
    changeCamera(
        CameraType.values.firstWhere((element) => element != _cameraType));
  }

  void switchFlashMode() {
    if (cameraType == CameraType.front) {
      flashMode =
          (flashMode == FlashMode.torch) ? FlashMode.off : FlashMode.torch;
    } else {
      flashMode =
          FlashMode.values[((flashMode.index + 1) % (FlashMode.values.length))];
    }
  }

  bool requiresFrontIllumination() =>
      (flashMode == FlashMode.torch) && (cameraType == CameraType.front);

  Future<File> takePicture() async {
    final xfile = await currentController!.takePicture();

    // File processing
    final processed = (cameraType == CameraType.front)
        ? (image.flipHorizontal(image.decodeImage(await xfile.readAsBytes())!))
        : image.decodeImage(await xfile.readAsBytes())!;

    // File (dart:io)
    final file =
        await File(xfile.path).writeAsBytes(image.encodeJpg(processed));

    return file;
  }
}

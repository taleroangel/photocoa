import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photocoa/providers/camera_hardware_provider.dart';
import 'package:photocoa/tools/alert_tools.dart';
import 'package:provider/provider.dart';

class Preview extends StatelessWidget {
  final double width;
  final double height;
  const Preview({required this.width, required this.height, super.key});

  @override
  Widget build(BuildContext context) {
    // Providers
    final cameraProvider = context.watch<CameraHardwareProvider>();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => cameraProvider.initialize());

    switch (cameraProvider.state) {
      case CameraHardwareState.ready:
        final controller = cameraProvider.currentController!;
        return SizedBox(
          height: height,
          width: width,
          child: FittedBox(
            clipBehavior: Clip.hardEdge,
            fit: BoxFit.cover,
            child: SizedBox(
                width: width,
                height: width * controller.value.aspectRatio,
                child: Stack(children: [
                  CameraPreview(controller),
                  AnimatedOpacity(
                    opacity:
                        cameraProvider.requiresFrontIllumination() ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withOpacity(0.9),
                              width: 80.0)),
                    ),
                  ),
                ])),
          ),
        );

      case CameraHardwareState.failed:
        // Show Snackbar
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            AlertTools.errorSnackbar(context,
                cameraProvider.exception?.description ?? "Unknown reason"));

        // Show error
        return Center(
          child: Text.rich(TextSpan(children: [
            const TextSpan(
                text: "Failed to initialize camera\n",
                style: TextStyle(color: Colors.red)),
            TextSpan(
                text: cameraProvider.exception?.description ?? "Unknown reason")
          ])),
        );

      /// Loading indicator
      case CameraHardwareState.busy:
        return const Center(child: CircularProgressIndicator());

      /// Uninitialized camera
      case CameraHardwareState.uninitialized:
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              children: const [
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: "Requesting camera permission\n",
                      style: TextStyle(color: Colors.amber)),
                  TextSpan(text: "Please accept camera permissions")
                ])),
                LinearProgressIndicator()
              ],
            ),
          ),
        );
    }
  }
}

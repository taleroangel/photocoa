import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photocoa/providers/camera_hardware_provider.dart';
import 'package:photocoa/screens/picture_save_screen.dart';
import 'package:photocoa/tools/alert_tools.dart';
import 'package:photocoa/widgets/preview_widget.dart';
import 'package:provider/provider.dart';

//TODO: Allow zooming
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    // Camera controller
    final cameraController = context.watch<CameraHardwareProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
          builder: (_, constraints) => Hero(
                tag: "main::camera",
                child: Stack(children: [
                  Preview(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight),
                  if (_busy)
                    Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      color: Colors.black38,
                    ),
                  if (_busy)
                    const Positioned(
                      bottom: 20,
                      right: 20,
                      child: CircularProgressIndicator(),
                    ),
                  if (_busy)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        "Processing photo\nThis may take a while",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                ]),
              )),
      persistentFooterAlignment: AlignmentDirectional.topStart,
      persistentFooterButtons: [
        Row(
          children: [
            _BottomActionButton(
              onPressed: Navigator.of(context).pop,
              color: Colors.white12,
              icon: Icons.arrow_back,
            ),
            _BottomActionButton(
              onPressed: cameraController.flipCamera,
              color: Colors.white24,
              icon: Icons.cameraswitch_sharp,
            ),
            _BottomActionButton(
              onPressed: () {
                cameraController.switchFlashMode();
                if (cameraController.requiresFrontIllumination() &&
                    (cameraController.flashMode == FlashMode.torch)) {
                  // Show information snackbar
                  AlertTools.infoSnackbar(context, "Bump up your brightness!");
                }
              },
              color: Colors.white24,
              icon: (cameraController.flashMode).toIcon(),
            ),
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () async {
                  if (_busy) {
                    AlertTools.infoSnackbar(context,
                        "Camera is busy, previous photo is still being processed");
                    return;
                  }

                  // Attempt photo
                  try {
                    // Play shutter click
                    GetIt.I
                        .get<AudioPlayer>()
                        .play(AssetSource('sound/shutter_click.mp3'));

                    setState(() {
                      _busy = true;
                    });

                    // Store navigator
                    final navigator = Navigator.of(context);

                    // Get the file and process it
                    final file = await cameraController.takePicture();

                    // Reproduce success sound
                    GetIt.I
                        .get<AudioPlayer>()
                        .play(AssetSource('sound/shutter_success.mp3'));

                    setState(() {
                      _busy = false;
                    });

                    // Push the route
                    navigator.push(
                        MaterialPageRoute(builder: (_) => PictureSave(file)));
                  } catch (e) {
                    AlertTools.errorSnackbar(context,
                        "Failed to take picture\nDetails: ${e.toString()}");
                  }
                },
                icon: const Icon(Icons.camera),
                label: const Text("Capture"),
              ),
            )
          ],
        )
      ],
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final Function()? onPressed;
  final IconData icon;
  final Color color;

  const _BottomActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: FloatingActionButton(
        heroTag: null,
        onPressed: onPressed,
        backgroundColor: color,
        child: Icon(icon),
      ),
    );
  }
}

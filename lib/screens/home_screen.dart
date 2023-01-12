// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:photocoa/providers/camera_hardware_provider.dart';
import 'package:photocoa/screens/camera_screen.dart';
import 'package:photocoa/screens/settings.dart';
import 'package:photocoa/widgets/preview_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        //* Camera Button
        Expanded(
          flex: 4,
          child: LayoutBuilder(
              builder: (_, constraints) => GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const CameraScreen())),
                    child: Stack(
                      children: [
                        // CameraPreview
                        Hero(
                          tag: "main::camera",
                          child: Preview(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight),
                        ),
                        // Gradient
                        if (context.watch<CameraHardwareProvider>().state ==
                            CameraHardwareState.ready)
                          Container(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(255),
                                ])),
                          ),

                        // Text
                        const Positioned(
                          bottom: 0,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Take a Picture",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            ),
                          ),
                        ),

                        const Positioned(
                            right: 0,
                            bottom: 0,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(
                                Icons.camera,
                                color: Colors.white,
                              ),
                            ))
                      ],
                    ),
                  )),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              //* Gallery Button
              Expanded(
                flex: 3,
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Stack(children: [
                    // Text
                    Positioned(
                      bottom: 0,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Gallery",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.photo_album,
                            color: Colors.white,
                          ),
                        ))
                  ]),
                ),
              ),

              //* Settings Button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Settings())),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Stack(children: [
                      // Text
                      Positioned(
                        bottom: 0,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Settings",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                      Positioned(
                          left: -50,
                          top: -60,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 140.0,
                            ),
                          ))
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

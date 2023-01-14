import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:native_exif/native_exif.dart';
import 'package:photocoa/tools/alert_tools.dart';
import 'package:photocoa/tools/datetime_tools.dart';

class PictureDetail extends StatelessWidget {
  final File file;
  const PictureDetail(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () async {
                final exif = await Exif.fromPath(file.path);
                final attributes = (await exif.getAttributes())!;
                final pretty = attributes.entries
                    .map(
                      (e) => '${e.key}: ${e.value}\n',
                    )
                    .reduce((value, element) => value + element)
                    .toString();

                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("About"),
                          content: Text.rich(TextSpan(text: pretty)),
                          actions: [
                            ElevatedButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text("Close"))
                          ],
                        ));
              },
              icon: const Icon(Icons.info)),
          IconButton(
              onPressed: () {
                showDialog<bool?>(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: const Text.rich(
                              TextSpan(text: "Delete this file?\n", children: [
                            TextSpan(
                                text: "This action is irreversible",
                                style: TextStyle(color: Colors.red))
                          ])),
                          actions: [
                            ElevatedButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text("Cancel")),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                                onPressed: () async {
                                  final navigator = Navigator.of(context);
                                  try {
                                    await file.delete();
                                    navigator.pop(true);
                                  } catch (e) {
                                    navigator.pop(false);
                                  }
                                },
                                child: const Text("Delete"))
                          ],
                        )).then((result) {
                  // When result is available
                  if (result != null && !result) {
                    AlertTools.errorSnackbar(
                        context, "Failed to delete picture");
                  } else if (result != null && result) {
                    AlertTools.infoSnackbar(
                        context, "Delete picture successfully");
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                });
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      ),
      body: Center(
        heightFactor: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            child: Hero(tag: 'picture::${file.path}', child: Image.file(file)),
          ),
        ),
      ),
    );
  }
}

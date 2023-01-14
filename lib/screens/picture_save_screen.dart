import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photocoa/tools/alert_tools.dart';

class PictureSave extends StatelessWidget {
  final File file;
  const PictureSave(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Save Picture")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.file(file),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      file // Delete the file
                          .delete()
                          .then((value) => AlertTools.infoSnackbar(
                              context, "Image discarded"))
                          .onError((error, stackTrace) =>
                              AlertTools.errorSnackbar(
                                  context, "Image deletion failed: $error"));
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete_forever),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    label: const Text("Discard")),
                ElevatedButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final path =
                          (await getApplicationDocumentsDirectory()).path;
                      final filePath = "$path/${basename(file.path)}";
                      file
                          .copy(filePath)
                          .then((value) => AlertTools.infoSnackbar(
                              context, "Image successfully saved "))
                          .onError((error, stackTrace) {
                        AlertTools.errorSnackbar(
                            context, "Image storage failed\n$error");
                        log(error.toString(),
                            level: DiagnosticLevel.error.index);
                      });

                      file.delete();
                      navigator.pop();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save")),
              ],
            ),
          )
        ],
      ),
    );
  }
}

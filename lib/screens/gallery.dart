import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photocoa/screens/picture_detail.dart';

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gallery")),
      body: Center(
          child: FutureBuilder(
        future: getApplicationDocumentsDirectory(),
        builder: (_, snapshot) =>
            (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData)
                ? _GalleryBuilder(snapshot.data!
                    .list()
                    .where((event) => (extension(event.path) == '.jpg'))
                    .map((event) => File(event.path)))
                : const CircularProgressIndicator(),
      )),
    );
  }
}

class _GalleryBuilder extends StatefulWidget {
  final Stream<File> fileStream;
  const _GalleryBuilder(this.fileStream, {Key? key}) : super(key: key);

  @override
  State<_GalleryBuilder> createState() => _GalleryBuilderState();
}

class _GalleryBuilderState extends State<_GalleryBuilder> {
  bool doneReading = false;
  Set<File> files = {};

  @override
  void initState() {
    super.initState();
    widget.fileStream
        .listen((event) => setState(() {
              files.add(event);
            }))
        .onDone(() => setState(() {
              doneReading = true;
            }));
  }

  @override
  void dispose() {
    files.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (files.isEmpty)
        ? (doneReading // If done reading
            ? const Text("Looks like you haven't taken any pictures yet")
            : const CircularProgressIndicator())
        : GridView.count(
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            crossAxisCount: 3,
            children: files.map((e) => _GalleryItemAdapter(e)).toList(),
          );
  }
}

class _GalleryItemAdapter extends StatelessWidget {
  final File file;
  const _GalleryItemAdapter(this.file, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PictureDetail(file),
      )),
      child: Hero(
        tag: 'picture::${file.path}',
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.cover,
            image: FileImage(file),
          )),
        ),
      ),
    );
  }
}

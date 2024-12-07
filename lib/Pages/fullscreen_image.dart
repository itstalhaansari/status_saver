import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:status_saver/Utils/functions.dart';
import 'package:status_saver/Utils/hivedb.dart';

class FullScreenImage extends StatefulWidget {
  const FullScreenImage({super.key, required this.imagePath});
  final String imagePath;

  @override
  FullScreenImageState createState() => FullScreenImageState();
}

class FullScreenImageState extends State<FullScreenImage> {
  late UserDataDb db;
  String targetDirectory = '';

  @override
  void initState() {
    super.initState();
    db = UserDataDb();
    db.loaddata(); // Load data from Hive
    // targetDirectory = db.getTargetDirectory(); // Get target directory after loading
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: PhotoView(
                  imageProvider: FileImage(File(widget.imagePath)),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  enableRotation: false,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.black)),
                onPressed: () => saveFile(
                  widget.imagePath,
                  context,
                ),
                child: const Icon(Icons.save, color: Colors.white),
              ),
              ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.black)),
                onPressed: () {
                  Sharefile(widget.imagePath, context);
                },
                child: const Icon(Icons.share, color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }
}

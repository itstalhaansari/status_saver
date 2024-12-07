import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:status_saver/Utils/functions.dart';
import 'package:status_saver/Utils/hivedb.dart';

class FullScreenImagesaved extends StatefulWidget {
  const FullScreenImagesaved({super.key, required this.imagePath});
  final String imagePath;

  @override
  FullScreenImagesavedState createState() => FullScreenImagesavedState();
}

class FullScreenImagesavedState extends State<FullScreenImagesaved> {
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
              Center(
                child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black)),
                  onPressed: () {
                    Sharefile(widget.imagePath, context);
                  },
                  child: const Icon(Icons.share, color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
